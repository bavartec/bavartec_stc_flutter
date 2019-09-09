package de.bavartec.stc

import android.os.CountDownTimer

class Timeout(
        millis: Long,
        private val onTimeout: () -> Unit
) {
    private val mTimer: CountDownTimer

    init {
        this.mTimer = createTimer(millis)
    }

    fun restart() {
        mTimer.cancel()
        mTimer.start()
    }

    fun stop() {
        mTimer.cancel()
    }

    private fun createTimer(millis: Long): CountDownTimer {
        return object : CountDownTimer(millis, millis) {
            override fun onTick(millisUntilFinished: Long) {}

            override fun onFinish() {
                onTimeout()
                stop()
            }
        }
    }
}