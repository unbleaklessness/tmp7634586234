#define S_FUNCTION_NAME MuJoCo
#define S_FUNCTION_LEVEL 2

#include <thread>
#include <atomic>
#include <mutex>

#include "simstruc.h"
#include "mujoco.h"
#include "glfw3.h"

mjModel *m = nullptr;
mjData *d = nullptr;
mjvCamera cam;
mjvOption opt;
mjvScene scn;
mjrContext con;

std::atomic<bool> running(false);
std::atomic<int> turn(0);
std::atomic<bool> mujocoInitialized(false);
std::mutex mutex;
std::thread mujocoThread;
std::thread glfwThread;

bool button_left = false;
bool button_middle = false;
bool button_right = false;
double last_x = 0.0;
double last_y = 0.0;

const mjtNum initialPositions[19] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
const mjtNum initialVelocities[18] = {0, 0, 0, 0, 0, 0, 0, -1047.1975511965977, 0, 1047.1975511965977, 0, 1047.1975511965977, 0, -1047.1975511965977, 0, 0, 0, 0};

bool connectedInputs[14];

void keyboard(GLFWwindow *window, int key, int scan_code, int act, int mods) {
    if (act == GLFW_PRESS && key == GLFW_KEY_BACKSPACE) {
        mutex.lock();
        mj_resetData(m, d);
        mju_copy(d->qpos, initialPositions, m->nq);
        mju_copy(d->qvel, initialVelocities, m->nv);
        mj_forward(m, d);
        mutex.unlock();
    }
}

void mouse_button(GLFWwindow *window, int button, int act, int mods) {
    button_left = (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS);
    button_middle = (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_MIDDLE) == GLFW_PRESS);
    button_right = (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS);

    glfwGetCursorPos(window, &last_x, &last_y);
}

void mouse_move(GLFWwindow *window, double xpos, double ypos) {
    if (!button_left && !button_middle && !button_right) {
        return;
    }

    double dx = xpos - last_x;
    double dy = ypos - last_y;
    last_x = xpos;
    last_y = ypos;

    int width, height;
    glfwGetWindowSize(window, &width, &height);

    bool mod_shift = (glfwGetKey(window, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS ||
                      glfwGetKey(window, GLFW_KEY_RIGHT_SHIFT) == GLFW_PRESS);

    mjtMouse action;
    if (button_right) {
        action = mod_shift ? mjMOUSE_MOVE_H : mjMOUSE_MOVE_V;
    } else if (button_left) {
        action = mod_shift ? mjMOUSE_ROTATE_H : mjMOUSE_ROTATE_V;
    } else {
        action = mjMOUSE_ZOOM;
    }

    mutex.lock();
    mjv_moveCamera(m, action, dx / height, dy / height, &scn, &cam);
    mutex.unlock();
}

void scroll(GLFWwindow *window, double x_offset, double y_offset) {
    mutex.lock();
    mjv_moveCamera(m, mjMOUSE_ZOOM, 0, -0.05 * y_offset, &scn, &cam);
    mutex.unlock();
}

void glfwLoop() {

    if (!glfwInit()) {
        running = false;
        ssPrintf("Could not initialize GLFW");
        return;
    }

    GLFWwindow *window = glfwCreateWindow(1200, 900, "MuJoCo", nullptr, nullptr);
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    mjv_defaultCamera(&cam);
    mjv_defaultOption(&opt);
    mjv_defaultScene(&scn);
    mjr_defaultContext(&con);

    mutex.lock();
    mjv_makeScene(m, &scn, 2000);
    mjr_makeContext(m, &con, mjFONTSCALE_150);
    mjv_updateScene(m, d, &opt, nullptr, &cam, mjCAT_ALL, &scn);
    mutex.unlock();

    glfwSetKeyCallback(window, keyboard);
    glfwSetCursorPosCallback(window, mouse_move);
    glfwSetMouseButtonCallback(window, mouse_button);
    glfwSetScrollCallback(window, scroll);

    mjrRect viewport = {0, 0, 0, 0};

    double previousTime = glfwGetTime();
    double currentTime = 0;
    double updateFrequency = 1 / 30;

    while (!glfwWindowShouldClose(window) && running.load()) {

        currentTime = glfwGetTime();
        if (currentTime - previousTime < updateFrequency) {
            continue;
        }

        glfwGetFramebufferSize(window, &viewport.width, &viewport.height);

        mutex.lock();
        mjv_updateScene(m, d, &opt, nullptr, &cam, mjCAT_ALL, &scn);
        mutex.unlock();

        mjr_render(viewport, &scn, &con);

        glfwSwapBuffers(window);

        glfwPollEvents();

        previousTime = currentTime;
    }

    running = false;

    mjv_freeScene(&scn);
    mjr_freeContext(&con);

#if defined(__APPLE__) || defined(_WIN32)
    glfwTerminate();
#endif
}

void mujocoLoop()
{
    mj_activate("mjkey.txt");

    const char xml_path[] = "MuJoCoModel.xml";
    const size_t error_size = 1000;
    char error[error_size] = "Could not load binary model";

    mutex.lock();

    m = mj_loadXML(xml_path, nullptr, error, error_size);
    if (!m) {
        running = false;
        ssPrintf("Load model error: %s", error);
        return;
    }

    d = mj_makeData(m);

    mju_copy(d->qpos, initialPositions, m->nq);
    mju_copy(d->qvel, initialVelocities, m->nv);

    mutex.unlock();

    glfwThread = std::thread(glfwLoop);

    mujocoInitialized = true;

    while (running.load()) {
        if (turn.load() == 1) {
            mutex.lock();

            mj_step(m, d);

            mutex.unlock();
            turn = 0;
        }
    }

    mujocoInitialized = false;

    glfwThread.join();

    mutex.lock();
    mj_deleteData(d);
    mj_deleteModel(m);
    mutex.unlock();

    mj_deactivate();
}

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return;
    }

    if (!ssSetNumInputPorts(S, 14)) {
        return;
    }

    for (int i = 0; i < 14; i++) {
        ssSetInputPortMatrixDimensions(S, i, 1, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    if (!ssSetNumOutputPorts(S, 20)) {
        return;
    }

    for (int i = 0; i < 20; i++) {
        ssSetOutputPortMatrixDimensions(S, i, 1, 1);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S) {
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

static void mdlOutputs(SimStruct *S, int_T tid) {}

#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid) {

    while (turn.load() != 0 || !mujocoInitialized.load()) {
        if (!running.load()) {
            ssSetStopRequested(S, 1);
            return;
        }
    }
    mutex.lock();

    for (int i = 0; i < 14; i++) {
        if (connectedInputs[i]) {
            d->ctrl[i] = *ssGetInputPortRealSignalPtrs(S, i)[0];
        }
    }

    for (int i = 0; i < 20; i++) {
        *ssGetOutputPortRealSignal(S, i) = d->sensordata[i];
    }

    mutex.unlock();
    turn = 1;
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    for (int i = 0; i < 14; i++) {
        connectedInputs[i] = ssGetInputPortConnected(S, i);
    }

    running = true;

    mujocoThread = std::thread(mujocoLoop);
}

static void mdlTerminate(SimStruct *S)
{
    running = false;

    mujocoThread.join();
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
