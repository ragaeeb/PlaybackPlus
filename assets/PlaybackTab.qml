import bb.cascades 1.0
import bb.cascades.pickers 1.0

NavigationPane
{
    id: navigationPane
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: mainPage
        actionBarVisibility: ChromeVisibility.Overlay
        
        titleBar: TitleBar {
            visibility: ChromeVisibility.Overlay
            
            function onMetaDataChanged(metadata) {
                var uri = metadata.uri;
                uri = uri.substring( uri.lastIndexOf("/")+1 );
                uri = uri.substring( 0, uri.lastIndexOf(".") );
                
                title = uri;
            }
            
            onCreationCompleted: {
                player.metaDataChanged.connect(onMetaDataChanged);
            }
        }
        
        actions: [
            ActionItem {
                title: qsTr("Load Media") + Retranslate.onLanguageChanged
                imageSource: "images/action_open.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    filePicker.directories = [persist.getValueFor("input"), "/accounts/1000/shared/videos"];
                    filePicker.open();
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                attachedObjects: [
                    FilePicker {
                        id: filePicker
                        filter: ["*.mkv", "*.mp4", "*.m4a", "*.ogg", "*.mp3", "*.amr", "*.aac", "*.flac", "*.mid", "*.wma", "*.3gp", "*.3g2", "*.asf", "*.avi", "*.mov", "*.f4v", "*.wmv", "*.wav"]
                        title: qsTr("Select Media") + Retranslate.onLanguageChanged
                        mode: FilePickerMode.PickerMultiple
                        
                        onFileSelected: {
                            persist.saveValueFor("recent", selectedFiles);
                            
                            var lastFile = selectedFiles[selectedFiles.length - 1];
                            var lastDir = lastFile.substring(0, lastFile.lastIndexOf("/") + 1);
                            persist.saveValueFor("input", lastDir);
                            
                            player.play(selectedFiles);
                        }
                    }
                ]
            },
            
            ActionItem {
                title: qsTr("Video") + Retranslate.onLanguageChanged
                imageSource: "images/ic_video_toggle.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: player.active
                shortcuts: [
                    Shortcut {
                        key: SystemShortcuts.Edit
                    }
                ]
                
                onTriggered: {
                    player.toggleVideo();
                }
            }
        ]
        
        ControlDelegate
        {
            id: videoDelegate
            property string videoWindowId: "myVideoSurface"
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            delegateActive: false
            
            function onActiveChanged()
            {
                if (player.active) {
                    delegateActive = true;
                    player.activeChanged.disconnect(onActiveChanged);
                }
            }
            
            onCreationCompleted: {
                player.setVideoWindowId(videoWindowId);
                player.activeChanged.connect(onActiveChanged);
            }
            
            sourceComponent: ComponentDefinition
            {
                Container
                {
                    id: rootContainer
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    layout: DockLayout {}
                    
                    gestureHandlers: [
                        TapHandler {
                            onTapped: {
                                controller.toggle();
                                mainPage.actionBarVisibility = mainPage.actionBarVisibility == ChromeVisibility.Overlay ? ChromeVisibility.Hidden : ChromeVisibility.Overlay;
                            }
                        },
                        
                        LongPressHandler {
                            id: longPressHandler
                            
                            onLongPressed: {
                                player.togglePlayback();
                            }
                        }
                    ]
                    
                    ForeignWindowControl
                    {
                        id: foreign
                        windowId: videoDelegate.videoWindowId
                        updatedProperties: WindowProperty.Size | WindowProperty.Position | WindowProperty.Visible
                        visible: boundToWindow
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        
                        attachedObjects: [
                            VideoSurfaceHandler {
                                id: videoHandler
                                surface: foreign
                            }
                        ]
                    }
                    
                    PlaybackControl {
                        id: controller
                        page: mainPage
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                    }
                }
            }
        }
    }
}