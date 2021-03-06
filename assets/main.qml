import bb.cascades 1.0
import com.canadainc.data 1.0

TabbedPane
{
    id: root
    activeTab: playTab
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
    
    onSidebarVisualStateChanged: {
        if (SidebarVisualState.AnimatingToVisibleCompact) {
            app.fetchAllBookmarks();
            app.fetchAllRecent();
        }
    }
    
    Menu.definition: CanadaIncMenu
    {
        projectName: "continuous-playback"
        
        onCreationCompleted: {
            addAction(brightnessAction);
        }
        
        attachedObjects: [
            ActionItem {
                id: brightnessAction
                title: qsTr("Brightness") + Retranslate.onLanguageChanged
                imageSource: "images/ic_brightness.png"
                
                onTriggered: {
                    app.invokeSettingsApp();
                }
            }
        ]
    }
    
    function lazyLoad(actualSource, tab) {
        definition.source = actualSource;
        
        var actual = definition.createObject();
        tab.content = actual;
        
        return actual;
    }
    
    Tab
    {
        id: playTab
        title: qsTr("Playback") + Retranslate.onLanguageChanged
        description: qsTr("Play") + Retranslate.onLanguageChanged
        imageSource: "images/ic_play.png"
        
        PlaybackTab {}
    }
    
    Tab {
        id: recent
        title: qsTr("Recent") + Retranslate.onLanguageChanged
        description: qsTr("Recently Played") + Retranslate.onLanguageChanged
        imageSource: "images/ic_open_recent.png"
        
        onTriggered: {
            if (! content) {
                var page = lazyLoad("RecentTab.qml", recent);
                page.recentSelected.connect(onFileSelected);
            }
        }
    }
    
    Tab {
        id: bookmarks
        title: qsTr("Bookmarks") + Retranslate.onLanguageChanged
        description: qsTr("Bookmarks & Notes") + Retranslate.onLanguageChanged
        imageSource: "images/ic_bookmarks.png"

        onTriggered: {
            if (!content) {
                var page = lazyLoad("BookmarksTab.qml", bookmarks);
                page.bookmarkSelected.connect(onFileSelected);
            }
        }
    }
    
    function onFileSelected(file, position)
    {
        lazyLoad("PlaybackTab.qml", playTab);
        playTab.triggered();
        activeTab = playTab;
        
        player.play(file);
        player.seek(position);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchRecent) {
            recent.unreadContentCount = data.length;
        } else if (id == QueryId.FetchBookmarks) {
            bookmarks.unreadContentCount = data.length;
        }
    }
    
    onCreationCompleted: {
        sql.dataLoaded.connect(onDataLoaded);
        
        if ( persist.getValueFor("tutorialCount") < 1 ) {
            persist.showToast( qsTr("Welcome to Playback Plus! Click on the Load Media action below to choose the media to play. You can select a combination of audio and video to play and they can be in different folders.\n\nYou can use the 'Video' action below to toggle the video on and off to conserve battery life if you have an audio-only video file."), qsTr("OK") );
            persist.saveValueFor("tutorialCount", 1);
        }
    }
}