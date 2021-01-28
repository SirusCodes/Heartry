import org.junit.*;
import org.junit.runner.*;
import org.junit.runners.*;
import org.junit.runners.JUnit4.*;

import tools.fastlane.screengrab.*;
// import tools.fastlane.screengrab.cleanstatusbar.*;

@RunWith(JUnit4.class)
public class MainScreenTest{
    @BeforeClass
    public static void beforeAll(){
        Screengrab.setDefaultScreenshotStrategy(new UiAutomatorScreenshotStrategy());

        // new CleanStatusBar()
            // .setMobileNetworkDataType(MobileDataType.FOURG)
            // .setBluetoothState(BluetoothState.DISCONNECTED)
            // .enable();
    }

    // @AfterClass
    // public static void afterAll(){
        // CleanStatusBar.disable();
    // }

    @Test
    public void testTakeScreenshot(){
        Screengrab.screenshot("LoginScreen");
    }
}
