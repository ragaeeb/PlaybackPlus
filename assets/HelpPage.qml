import bb.cascades 1.0
import bb 1.0

Page
{
    titleBar: TitleBar {
        title: qsTr("Help") + Retranslate.onLanguageChanged
    }
    
    attachedObjects: [
        ApplicationInfo {
            id: appInfo
        },

        PackageInfo {
            id: packageInfo
        }
    ]

    Container
    {
        leftPadding: 20; rightPadding: 20

        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Fill

        ScrollView {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill

            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSize: FontSize.Small
                content.flags: TextContentFlag.ActiveText
                text: qsTr("(c) 2013 %1. All Rights Reserved.\n%2 %3\n\nPlease report all bugs to:\nsupport@canadainc.org\n\nThis app allows the user to keep a video playing in the background while the user does other work (which does not work with the standard native video player). To maximize battery life, the BlackBerry 10 native Video app pauses the media on almost any external action that is done on it. The video needs to then be resumed if you just want to check your email, or an incoming message. Although this is a really good battery saving strategy, users might want to disable this.\n\nTo work around this, Playback Plus (Background Video 10) was developed. This app allows you to keep playing the video in the background and listening to the audio while you do whatever work it is you need to. If you have audio-only videos (ie: videos where you are only interested in the speech like some Youtube videos), you can simply turn off your display and you can maximize battery life with this app. Another way to conserve battery life for these audio-only videos is that the app will allow you to toggle the Video window off completely to further maximize battery.\n\nAdditionally this app supports playlists, so you can queue up multiple videos to play one after another.\n\nPlayback Plus was developed with user experience and ease in mind, and thus it incorporates a nice UI look and feel and makes it easy for the user to be efficient.\n\nPlayack Plus also remembers the last position you leave off a video, so it will automatically resume it once you load it again from the recent tab.").arg(packageInfo.author).arg(appInfo.title).arg(appInfo.version)
            }
        }
    }
}
