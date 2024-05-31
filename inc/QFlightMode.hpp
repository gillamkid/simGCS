#pragma once
#include <QObject>
#include <QMetaEnum>
#include <QQmlContext>

/// @brief A FlightMode enum with some extra stuff for using it in QML
class QFlightMode : public QObject {
    Q_OBJECT
public:
    QFlightMode(QObject *parent = nullptr) : QObject(parent) {}

    enum FlightMode {
        GROUND,     // vehicle is grounded and not moving
        TAKEOFF,    // vehicle ascends to a safe altitude to perform "hold" or "goTo" mode
        HOLD,       // vehicle loiters in the air at a fixed location
        GOTO,       // vehicle moves horizontally towards its GoTo location
        LAND,       // vehicle descends and parks on ground
    };

    Q_ENUM(FlightMode)

    Q_INVOKABLE static QString toString(int flightMode) {
        static QMetaEnum meta = QMetaEnum::fromType<FlightMode>();
        return meta.valueToKey(flightMode);
    }
};
typedef QFlightMode::FlightMode FlightMode;

/// @brief  Use when registering the Q_ENUM for use in QML
static QObject *q_flight_mode_singleton_provider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    // Create a static instance
    static QFlightMode instance;
    return &instance;
}
