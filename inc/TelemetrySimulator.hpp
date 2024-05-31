#pragma once
#include <QtPositioning/QGeoCoordinate>
#include <QTimer>
#include "QFlightMode.hpp"
#include "QMacros.hpp"

/// @brief A quad-copter simulator that can change flight modes and updates its position
/// depending on the current flight mode
class TelemetrySimulator : public QObject
{
    Q_OBJECT

    Q_READONLY_PROPERTY(int, flightMode, FlightMode::GROUND)
    Q_READONLY_PROPERTY(double, batteryPercent, 99)
    Q_READONLY_PROPERTY(double, speed_mps, 0)
    Q_READONLY_PROPERTY(double, heading_deg, 0)
    Q_READONLY_PROPERTY(QGeoCoordinate, location, QGeoCoordinate(51.5072, -0.127, 0)) // London
    Q_READONLY_PROPERTY(QGeoCoordinate, goToTarget, QGeoCoordinate())

public:
    explicit TelemetrySimulator(QObject *parent = nullptr);

    Q_INVOKABLE void takeoff();
    Q_INVOKABLE void hold();
    Q_INVOKABLE void land();
    Q_INVOKABLE void goTo(QGeoCoordinate coord);

private:
    static constexpr double BATTERY_DEPLETION_PERCENT_PER_SEC = 0.1;
    static constexpr int UPDATE_FREQ_HZ = 20;
    QTimer *m_updateTimer;

    /// @brief updates the simulations position, battery, flight mode, etc. based on how
    /// much time has passed since the last time update() was called.
    void update();
};
