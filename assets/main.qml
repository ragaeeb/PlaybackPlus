import bb.cascades 1.0
import bb.multimedia 1.0
import CustomComponent 1.0
import bb.device 1.0

NavigationPane
{
    id: navigationPane

    property variant playlist
    property int currentTrack: 0
    
    attachedObjects: [
        NowPlayingConnection {
            id: nowPlaying
            connectionName: "myConnection"
            
            onAcquired: {
                player.reset()
                doPlay();
            }
            
            onPause: {
                player.pause()
            }
            
            onRevoked: {
                player.stop()
            }
        },
        
        MediaPlayer {
            id: player
            videoOutput: VideoOutput.PrimaryDisplay
            windowId: videoSurface.windowId
            
            onPlaybackCompleted: {
                //console.log("playbackCompleted")
                player.positionChanged(0);
                skip(1);
            }
            
		    onDurationChanged: {
		        seeker.toValue = duration
		        seekerLabel.durationText = formatTime(duration)
		    }
            
            onPositionChanged: {
                seeker.value = position
                seekerLabel.positionText = formatTime(position)
            }
            
            onVideoDimensionsChanged:
            {
                if ( persist.getValueFor("stretch") == 0 )
                {
                    rootContainer.horizontalAlignment = HorizontalAlignment.Center
                    rootContainer.verticalAlignment = VerticalAlignment.Center
                    
	                if (orientationHandler.orientation == UIOrientation.Landscape) {
	                    if (videoDimensions.width > videoDimensions.height) { // src is landscape and device is portrait
	                        rootContainer.preferredWidth = displayInfo.pixelSize.height
	                        rootContainer.preferredHeight = (displayInfo.pixelSize.height/videoDimensions.width)*videoDimensions.height
	                    } else { // device is landscape and src is portrait
	                        rootContainer.preferredHeight = displayInfo.pixelSize.width
	                        rootContainer.preferredWidth = (displayInfo.pixelSize.width/videoDimensions.height)*videoDimensions.width
	                    }
	                } else {
	                    if (videoDimensions.width > videoDimensions.height) { // device is portrait and src is landscape
	                        rootContainer.preferredWidth = displayInfo.pixelSize.width
	                        rootContainer.preferredHeight = (displayInfo.pixelSize.width/videoDimensions.width)*videoDimensions.height
	                    } else { // device is portrait, src is portrait
	                        rootContainer.preferredHeight = displayInfo.pixelSize.height
	                        rootContainer.preferredWidth = (displayInfo.pixelSize.height/videoDimensions.height)*videoDimensions.width
	                    }
	                }
	            } else {
	                rootContainer.resetPreferredSize()
	                rootContainer.horizontalAlignment = HorizontalAlignment.Fill
	                rootContainer.verticalAlignment = VerticalAlignment.Fill
	            }
            }
        },
        
		OrientationHandler {
		    id: orientationHandler
		    
		    onOrientationChanged: {
		        player.videoDimensionsChanged(player.videoDimensions)
		    }
        },
        
        ComponentDefinition {
            id: definition
        }
    ]

    Menu.definition: CanadaIncMenu
    {
        projectName: "oct-10"
        
        onCreationCompleted: {
            addAction(updateAction);
        }
        
        attachedObjects: [
            ActionItem {
                title: qsTr("Brightness") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/action_set.png"
                
                onTriggered: {
                    app.invokeSettingsApp()
                }
            }
        ]
    }
    
    function doPlay()
    {
        if (nowPlaying.acquired) {
            mainPage.actionBarVisibility = ChromeVisibility.Hidden;
            rootContainer.showControls = false;
            player.play();
        } else {
            nowPlaying.acquire()
        }
    }
    
    function playFile(file)
    {
        trackTitle.text = file.substring( file.lastIndexOf("/")+1 )
        cover.currentFile = trackTitle.text
        
		player.stop()
		
		if ( file.indexOf("file://") == -1 ) {
		    file = "file://"+file
		}
		
		player.sourceUrl = file
		
		doPlay();
    }
    
    
    function skip(n)
    {
        //console.log("skip", currentTrack, n, playlist.length)
        var desired = currentTrack+n;
		
		if (desired >= 0 && desired < playlist.length) {
		    currentTrack = desired;
		    playFile(playlist[currentTrack]);
		} else {
		    //console.log("out of bounds!")
		    player.reset();
            player.sourceUrl = "";
            mainPage.actionBarVisibility = ChromeVisibility.Overlay;
            rootContainer.showControls = false;
        }
    }
    
    
    function toggleControls()
    {
        rootContainer.showControls = !rootContainer.showControls && player.mediaState == MediaState.Started;
        mainPage.actionBarVisibility = mainPage.actionBarVisibility == ChromeVisibility.Overlay ? ChromeVisibility.Hidden : ChromeVisibility.Overlay;
    }
    
    
    function formatTime(position)
    {
		var secs = Math.floor(position / 1000) % 60
        var mins = Math.floor((position / (1000 * 60) ) % 60)
        var hrs = Math.floor((position / (1000 * 60 * 60) ) % 24);
		
		var seconds = secs >= 10 ? "%1".arg(secs) : "0%1".arg(secs)
		var minutes = mins >= 10 ? "%1".arg(mins) : "0%1".arg(mins)
		var hours = hrs > 0 ? "%1:".arg(hrs) : ""
		
		return qsTr("%1%2:%3").arg(hours).arg(minutes).arg(seconds)
    }

    onPopTransitionEnded: {
        page.destroy();
    }
    
    BasePage
    {
        id: mainPage

        shortcuts: [
            SystemShortcut {
                type: SystemShortcuts.NextSection
                
                onTriggered: {
                    skip(1)
                }
            },
            
            SystemShortcut {
                type: SystemShortcuts.PreviousSection
                
                onTriggered: {
                    skip(-1)
                }
            },
                        
            SystemShortcut {
                type: SystemShortcuts.JumpToTop
                
                onTriggered: {
                    skip(0)
                }
            },
                                    
            SystemShortcut {
                type: SystemShortcuts.Edit
                
                onTriggered: {
	                if ( player.mediaState == MediaState.Started ) {
	                    player.pause()
	                } else {
                        doPlay();
                    }
                }
            }
        ]
        
        actionBarVisibility: ChromeVisibility.Overlay
        
        actions: [
        	ActionItem {
                id: loadAction
                title: qsTr("Load Media") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/action_open.png"
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
                        type: FileType.Video
                        title: qsTr("Select Video") + Retranslate.onLanguageChanged
                        mode: FilePickerMode.PickerMultiple
                        directories: {
                            return [ persist.getValueFor("input"), "/accounts/1000/shared/videos" ]
                        }

                        onFileSelected: {
                            playlist = selectedFiles
                            currentTrack = 0;
                            skip(currentTrack)
                            persist.saveValueFor("recent", selectedFiles)

                            var lastFile = selectedFiles[selectedFiles.length - 1];
                            var lastDir = lastFile.substring(0, lastFile.lastIndexOf("/") + 1)
                            persist.saveValueFor("input", lastDir)

                            filePicker.directories = [ lastDir, "/accounts/1000/shared/videos" ]
                        }
                    }
                ]
            },
        	
            ActionItem {
                id: playAction
                title: player.mediaState == MediaState.Started ? qsTr("Pause") : qsTr("Play")
                imageSource: player.mediaState == MediaState.Started ? "asset:///images/ic_pause.png" : "asset:///images/ic_play.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: player.mediaState == MediaState.Started || player.mediaState == MediaState.Paused;

                onTriggered: {
	                longPressHandler.longPressed(0)
                }
            }
        ]
        
        contentContainer: Label
        {
            text: qsTr("Welcome to BV10.\n\nChoose your media by tapping on the Load Media action in the action bar.\n\nTo pause/resume playback at any point press-and-hold on the video.\n\nTo skip to the next/prev video you can swipe left/right respectively.") + Retranslate.onLanguageChanged
            multiline: true
            textStyle.fontSize: FontSize.XXSmall
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            textStyle.textAlign: TextAlign.Center
        }

        rootContainer: Container
        {
            property bool showControls: false
            
            id: rootContainer
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center

	        layout: DockLayout {}
	        
	        attachedObjects: [
	            DisplayInfo {
	                id: displayInfo
	            }
	        ]
	        
	        ForeignWindowControl
	        {
				property int downX;
				property int downY;
	            
	            id: videoSurface
	            windowId: "myVideoSurface"
	            updatedProperties: WindowProperty.Size | WindowProperty.Position | WindowProperty.Visible
	            visible: boundToWindow
	            horizontalAlignment: HorizontalAlignment.Center
	            verticalAlignment: VerticalAlignment.Center
	            
	            gestureHandlers: [
	                TapHandler {
	                    onTapped: {
	                        toggleControls();
	                        
                            leftShift.animate()
	                        
	                        if ( currentTrack < playlist.length-1) {
    	                        leftShift.animate()
	                        }
	                        
	                        if ( currentTrack > 0 && playlist.length > 1) {
    	                        rightShift.animate()
	                        }
	                    }
                    },
                    
                    LongPressHandler {
                        id: longPressHandler
                        onLongPressed: {
                            if ( player.mediaState == MediaState.Started ) {
                                player.pause()
                            } else {
                                doPlay();
                            }
                        }
                    }
	            ]
	            
			    onTouch: {
			        if (event.isDown()) {
			            downX = event.windowX;
			            downY = event.windowY;
			        } else if (event.isUp()) {
			            var yDiff = downY - event.windowY;
			            var xDiff = downX - event.windowX;
			            // take absolute value of yDiff
			            if (yDiff < 0) yDiff = -1 * yDiff;
			            if (xDiff < 0) xDiff = -1 * xDiff;
			            // I check if the minimum y movement is less than 200.  Don't want to move left or right if
			            // the user is actually want to move up or down.
			            if ((yDiff) < 200) {
			                if ((downX - event.windowX) > 320) {
			                    skip(1)
			                } else if ((event.windowX - downX) > 320) {
			                    skip(-1)
			                }
			            }
			        }
			    }
	        }
	        
	        HintLabel {
	            id: leftShift
	            toValue: -500
	            text: "<<<"
	        }
	        
	        HintLabel {
	            id: rightShift
	            toValue: 500
	            text: ">>>"
	        }
	        
	        Container
	        {
			    horizontalAlignment: HorizontalAlignment.Fill
			    verticalAlignment: VerticalAlignment.Center

				Slider {
				    id: seeker
				    visible: rootContainer.showControls
				    horizontalAlignment: HorizontalAlignment.Fill
				    
				    onTouch: {
				        if ( event.isUp() ) {
				            player.seek(player.track, immediateValue)
				            timer.start(3000)
				        } else if ( event.isMove() ) {
				            seekerLabel.positionText = formatTime(immediateValue)
				        } else if ( event.isDown() ) {
				            timer.stop()
				        }
				    }
				}
				
				Label {
				    id: trackTitle
				    textStyle.fontSize: FontSize.XXSmall
				    horizontalAlignment: HorizontalAlignment.Fill
				    textStyle.textAlign: TextAlign.Center
				    verticalAlignment: VerticalAlignment.Top
				    visible: rootContainer.showControls
				}
		        
				Label {
					property string positionText
					property string durationText
					
				    id: seekerLabel
		            text: qsTr("%1 / %2").arg(positionText).arg(durationText)
				    textStyle.fontSize: FontSize.XXSmall
				    horizontalAlignment: HorizontalAlignment.Fill
				    textStyle.textAlign: TextAlign.Center
				    verticalAlignment: VerticalAlignment.Bottom
				    visible: rootContainer.showControls
				}
	        }
        }
    }
}