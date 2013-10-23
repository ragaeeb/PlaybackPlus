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
            },
            
            DeleteActionItem {
                title: qsTr("Delete") + Retranslate.onLanguageChanged
                enabled: player.active
                
                onTriggered: {
                    prompt.show();
                }
                
                attachedObjects: [
                    SystemDialog {
                        id: prompt
                        title: qsTr("Confirmation") + Retranslate.onLanguageChanged
                        body: qsTr("Are you sure you want to delete this file?") + Retranslate.onLanguageChanged
                        confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
                        cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged
                        includeRememberMe: true
                        rememberMeChecked: false
                        rememberMeText: qsTr("Also delete bookmarks associated with file.") + Retranslate.onLanguageChanged
                        
                        onFinished: {
                            if (result == SystemUiResult.ConfirmButtonSelection)
                            {
                                player.stop();
                                var deleted = app.deleteFile( player.metaData.uri, prompt.rememberMeSelection() );
                                
                                if (deleted) {
                                    persist.showToast( qsTr("Deleted file!") );
                                } else {
                                    persist.showToast( qsTr("Could not delete file!") );
                                }
                            }
                        }
                    }
                ]
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
                        },
                        
                        DoubleTapHandler
                        {
                            property variant notesDialog
                            
                            onDoubleTapped: {
                                if (!notesDialog) {
                                    definition.source = "NotesDialog.qml";
                                    notesDialog = definition.createObject();
                                }

                                notesDialog.position = player.position;
                                notesDialog.open();
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