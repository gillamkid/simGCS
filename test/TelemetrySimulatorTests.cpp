#include <gtest/gtest.h>
#include <QGuiApplication>
#include "TelemetrySimulator.hpp"

TEST(TelemetrySimulatorTests, initialState)
{
    TelemetrySimulator sim;
    ASSERT_EQ(sim.flightMode(), FlightMode::GROUND);
    ASSERT_EQ(sim.speed_mps(), 0);
    ASSERT_TRUE(sim.location().isValid());
}

TEST(TelemetrySimulatorTests, takeoff)
{
    TelemetrySimulator sim;
    sim.takeoff();
    ASSERT_EQ(sim.flightMode(), FlightMode::TAKEOFF);
}

TEST(TelemetrySimulatorTests, goTo)
{
    TelemetrySimulator sim;
    sim.takeoff();
    sim.goTo({1,2,3});
    ASSERT_EQ(sim.flightMode(), FlightMode::GOTO);
    ASSERT_EQ(sim.goToTarget().latitude(), 1);
    ASSERT_EQ(sim.goToTarget().longitude(), 2);
    ASSERT_EQ(sim.goToTarget().altitude(), 3);
}

TEST(TelemetrySimulatorTests, land)
{
    TelemetrySimulator sim;
    sim.takeoff();
    sim.land();
    ASSERT_EQ(sim.flightMode(), FlightMode::LAND);
}

// TelemetrySimulator uses a QTimer, so we have our own main() instead of
// linking to gtest_main to avoid warnings.
int main(int argc, char **argv) {
    QCoreApplication app(argc, argv);

    ::testing::InitGoogleTest(&argc, argv);
    int ret = RUN_ALL_TESTS();

    QTimer exitTimer;
    QObject::connect(&exitTimer, &QTimer::timeout, &app, QCoreApplication::quit);
    exitTimer.start();
    app.exec();
    return ret;
}
