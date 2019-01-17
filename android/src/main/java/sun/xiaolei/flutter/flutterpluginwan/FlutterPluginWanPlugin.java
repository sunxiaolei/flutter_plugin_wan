package sun.xiaolei.flutter.flutterpluginwan;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPluginWanPlugin
 */
public class FlutterPluginWanPlugin implements MethodCallHandler {

    Context mContext;

    public FlutterPluginWanPlugin(Context context) {
        mContext = context;
    }

    private final static String CHANNEL_NATIVE = "channel_native";
    private final static String METHOD_SHARE = "method_share";
    private final static String METHOD_COPY = "method_copy";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NATIVE);
        channel.setMethodCallHandler(new FlutterPluginWanPlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case METHOD_SHARE:
                share((String) call.arguments);
                break;
            case METHOD_COPY:
                copy((List<String>) call.arguments);
                break;
        }
    }

    private void share(String args) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_SUBJECT, "WanFlutter");
        intent.putExtra(Intent.EXTRA_TEXT, args);
        mContext.startActivity(Intent.createChooser(intent, "分享"));

    }

    private void copy(final List<String> args) {
        final ClipboardManager cmb = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        cmb.setPrimaryClip(ClipData.newPlainText("text", args.get(0)));
        Toast.makeText(mContext, args.get(1), Toast.LENGTH_SHORT).show();
    }
}
