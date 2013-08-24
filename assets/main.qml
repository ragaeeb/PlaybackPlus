import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.multimedia 1.0

NavigationPane
{
    id: navigationPane

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

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
                imageSource: "images/action_set.png"
                
                onTriggered: {
                    app.invokeSettingsApp()
                }
            }
        ]
    }

    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: mainPage
        actionBarVisibility: ChromeVisibility.Overlay
        
        actions: [
        	ActionItem {
                title: qsTr("Load Media") + Retranslate.onLanguageChanged
                imageSource: "images/action_open.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
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
                        title: qsTr("Select Video") + Retranslate.onLanguageChanged
                        mode: FilePickerMode.PickerMultiple
                        directories: {
                            return [ persist.getValueFor("input"), "/accounts/1000/shared/videos" ]
                        }

                        onFileSelected: {
                            persist.saveValueFor("recent", selectedFiles);

                            var lastFile = selectedFiles[selectedFiles.length - 1];
                            var lastDir = lastFile.substring(0, lastFile.lastIndexOf("/") + 1);
                            persist.saveValueFor("input", lastDir);

                            filePicker.directories = [ lastDir, "/accounts/1000/shared/videos" ];
                            
                            player.play(selectedFiles);
                        }
                    }
                ]
            },
        	
            ActionItem {
                title: qsTr("Video")
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
                    delegateActive = player.active;
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
                        /*
                         attachedObjects: [
                         VideoSurfaceHandler {
                         id: videoHandler
                         surface: rootContainer
                         }
                         ]*/
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