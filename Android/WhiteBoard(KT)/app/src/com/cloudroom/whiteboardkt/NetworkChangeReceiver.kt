package com.cloudroom.whiteboardkt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.net.wifi.WifiManager
import android.os.Parcelable

class NetworkChangeReceiver : BroadcastReceiver() {
    private var mWifiConnect: Boolean = false
    private var mCellularConnect: Boolean = false
    private var mCurrentNetworkStateActive: Boolean = true
    private var mListener: (Boolean) -> Unit = {}

    fun addOnNetWorkChangeListener(listener: (Boolean) -> Unit) {
        mListener = listener
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (WifiManager.NETWORK_STATE_CHANGED_ACTION == intent.action) {
            val parcelableExtra = intent
                    .getParcelableExtra<Parcelable>(WifiManager.EXTRA_NETWORK_INFO)
            if (null != parcelableExtra) {
                val networkInfo = parcelableExtra as NetworkInfo
                val state = networkInfo.state
                val isConnected = state == NetworkInfo.State.CONNECTED
                mWifiConnect = isConnected
            }
        }
        if (ConnectivityManager.CONNECTIVITY_ACTION == intent.action) {
            val manager = context
                    .getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val activeNetwork = manager.activeNetworkInfo
            if (activeNetwork != null) { // connected to the internet
                if (activeNetwork.isConnected) {
                    mCellularConnect = false
                    mWifiConnect = false
                    when (activeNetwork.type) {
                        ConnectivityManager.TYPE_WIFI -> {
                            // connected to wifi
                            mWifiConnect = true
                        }
                        ConnectivityManager.TYPE_MOBILE -> {
                            // connected to the mobile provider's data plan
                            mCellularConnect = true
                        }
                        ConnectivityManager.TYPE_ETHERNET -> {
                            //连接以太网
                            mCellularConnect = true
                        }
                    }
                } else {
                    mWifiConnect = false
                    mCellularConnect = false
                }
            } else {   // not connected to the internet
                mWifiConnect = false
                mCellularConnect = false
            }
        }
        if (mWifiConnect || mCellularConnect) {
            if (!mCurrentNetworkStateActive) {
                mCurrentNetworkStateActive = true
                mListener(true)
            }
        } else if (!mWifiConnect && !mCellularConnect) {
            if (mCurrentNetworkStateActive) {
                mCurrentNetworkStateActive = false
                mListener(false)
            }
        }
    }
}