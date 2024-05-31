#pragma once
#include <QObject>

// Creates a property that is readonly from QML but settable from the C++ backend.
#define Q_READONLY_PROPERTY(T, prop, initialValue)                                      \
    _Q_READONLY_PROPERTY(T, prop, initialValue, prop##Changed, set_##prop, m_##prop)

#define _Q_READONLY_PROPERTY(T, prop, initialValue, propChanged, set_prop, m_prop)      \
    Q_PROPERTY(T prop READ prop NOTIFY propChanged)                                     \
public:                                                                                 \
    T prop() const { return m_prop; }                                                   \
    Q_SIGNAL void propChanged();                                                        \
    void set_prop(const T &val)                                                         \
    {                                                                                   \
        if (m_prop != val) {                                                            \
            m_prop = val;                                                               \
            emit propChanged();                                                         \
        }                                                                               \
    }                                                                                   \
private:                                                                                \
    T m_prop{initialValue};
