package com.flutter.bugly.flutter_bugly

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.Process
import android.text.TextUtils
import com.hjq.permissions.OnPermissionCallback
import com.hjq.permissions.Permission
import com.hjq.permissions.XXPermissions
import com.tencent.bugly.Bugly
import com.tencent.bugly.beta.Beta
import com.tencent.bugly.crashreport.CrashReport
import com.tencent.bugly.crashreport.CrashReport.UserStrategy
import java.io.BufferedReader
import java.io.FileReader
import java.io.IOException


object FlutterBuglyCrash {

    private var mActivity: Activity? = null
    /**
     * @param appId
     * @param debug 调试模式开关
     * @param appReportDelay 初始化延迟时间
     * @param devDevice 设置开发设备
     */
    fun initCrashReport(
        mActivity: Activity,
        appId: String,
        debug: Boolean = false,
        appReportDelay: Int = 5000,
        devDevice: Boolean = false
    ) {
        this.mActivity=mActivity;
        /**
         * 适配安卓11以上权限 解决java.lang.SecurityException: getDataNetworkTypeForSubscriber
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) { //Android 11 授权读写权限
            XXPermissions.with(mActivity)
                .permission(Permission.READ_PHONE_STATE)
                .request(OnPermissionCallback { permissions, allGranted ->
                    if (allGranted) {
                        // 获取当前包名
                        val packageName = mActivity!!.applicationContext.packageName
                        // 获取当前进程名
                        val processName = getProcessName(Process.myPid())
                        // 设置是否为上报进程
                        val strategy = UserStrategy(mActivity!!.applicationContext)
                        strategy.appReportDelay = appReportDelay.toLong()
                        strategy.isUploadProcess =
                            processName == null || processName == packageName
                        CrashReport.setIsDevelopmentDevice(mActivity!!.applicationContext, devDevice)
                        Bugly.init(mActivity!!.applicationContext, appId, debug)
                        initBuglyUpdate()
                    }
                })
        } else {
            // 获取当前包名
            val packageName = mActivity!!.applicationContext.packageName
            // 获取当前进程名
            val processName = getProcessName(Process.myPid())
            // 设置是否为上报进程
            val strategy = UserStrategy(mActivity!!.applicationContext)
            strategy.appReportDelay = appReportDelay.toLong()
            strategy.isUploadProcess =
                processName == null || processName == packageName
            CrashReport.setIsDevelopmentDevice(mActivity!!.applicationContext, devDevice)
            Bugly.init(mActivity!!.applicationContext.applicationContext, appId, debug)
            initBuglyUpdate()
        }
    }


    fun initBuglyUpdate() {
        Beta.autoInit = true
        Beta.autoCheckAppUpgrade = true
        Beta.upgradeCheckPeriod = 60 * 1000
        Beta.storageDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        Beta.showInterruptedStrategy = true
        Beta.enableNotification = true
        Beta.autoDownloadOnWifi = true
        Beta.canShowApkInfo = true
        Beta.enableHotfix = false
    }

    fun setUserId(userId: String) {
        /**
         * 适配安卓11以上权限 解决java.lang.SecurityException: getDataNetworkTypeForSubscriber
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) { //Android 11 授权读写权限
            XXPermissions.with(mActivity!!.applicationContext)
                .permission(Permission.READ_PHONE_STATE)
                .request(OnPermissionCallback { permissions, allGranted ->
                    if (allGranted) {
                        CrashReport.setUserId(userId)
                    }
                })
        } else {
            CrashReport.setUserId(userId)
        }

    }

    fun postException(error: String?, stackTrace: String?) {
        /**
         * 适配安卓11以上权限 解决java.lang.SecurityException: getDataNetworkTypeForSubscriber
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) { //Android 11 授权读写权限
            XXPermissions.with(mActivity!!.applicationContext)
                .permission(Permission.READ_PHONE_STATE)
                .request(OnPermissionCallback { permissions, allGranted ->
                    if (allGranted) {
                        CrashReport.postException(
                            4,
                            "Flutter Exception",
                            error,
                            stackTrace,
                            null
                        )
                    }
                })
        } else {
            CrashReport.postException(
                4,
                "Flutter Exception",
                error,
                stackTrace,
                null
            )
        }
    }

    /**
     * @param key 限长50字节，正则匹配[a-zA-Z[0-9]]+
     * @param value 限长200字节
     */
    fun putUserData(context: Context, key: String?, value: String?) {
        if (key.isNullOrBlank() || value.isNullOrBlank()) {
            return
        }
        /**
         * 适配安卓11以上权限 解决java.lang.SecurityException: getDataNetworkTypeForSubscriber
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) { //Android 11 授权读写权限
            XXPermissions.with(context)
                .permission(Permission.READ_PHONE_STATE)
                .request(OnPermissionCallback { permissions, allGranted ->
                    if (allGranted) {
                        CrashReport.putUserData(context, key, value)
                    }
                })
        } else {
            CrashReport.putUserData(context, key, value)
        }
    }

    /**
     * 测试
     */
    fun testJavaCrash() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) { //Android 11 授权读写权限

            XXPermissions.with(mActivity!!.applicationContext)
                .permission(Permission.READ_PHONE_STATE)
                .request(OnPermissionCallback { permissions, allGranted ->
                    if (allGranted) {
                        CrashReport.testJavaCrash()
                    }
                })
        }else{
            CrashReport.testJavaCrash()
        }
    }

    /**
     * 获取进程号对应的进程名
     *
     * @param pid 进程号
     * @return 进程名
     */
    fun getProcessName(pid: Int): String? {
        var reader: BufferedReader? = null
        try {
            reader = BufferedReader(FileReader("/proc/$pid/cmdline"))
            var processName = reader.readLine()
            if (!TextUtils.isEmpty(processName)) {
                processName = processName.trim { it <= ' ' }
            }
            return processName
        } catch (throwable: Throwable) {
            throwable.printStackTrace()
        } finally {
            try {
                reader?.close()
            } catch (exception: IOException) {
                exception.printStackTrace()
            }
        }
        return null
    }
}