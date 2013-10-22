import bb.cascades 1.0
import com.canadainc.data 1.0
import bb.multimedia 1.0

Container
{
    id: root
    property Page page
    
    horizontalAlignment: HorizontalAlignment.Fill
	
	function toggle()
	{
	    if (visible) {
	        fadeOut.play();
	    } else {
	        fadeIn.play();
	    }
	}
    
    Container
    {
        verticalAlignment: VerticalAlignment.Fill
        horizontalAlignment: HorizontalAlignment.Fill
        layout: DockLayout {}
        
        Container {
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            background: Color.Black
            opacity: 0.5
        }
        
        Container
        {
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            
            Slider {
                id: seeker
                property bool touchedDown: false
                horizontalAlignment: HorizontalAlignment.Fill
                
                onTouch: {
                    if ( event.isUp() ) {
                        player.seek(immediateValue);
                        timer.refresh();
                        touchedDown = false;
                    } else if ( event.isMove() ) {
                        seekerLabel.positionText = textUtils.formatTime(immediateValue);
                    } else if ( event.isDown() ) {
                        timer.stop();
                        touchedDown = true;
                    }
                }
                
                onCreationCompleted: {
                    player.durationChanged.connect( function(duration) {
                        toValue = duration;
                    });
                
	                player.positionChanged.connect( function(position) {
	                    if (!touchedDown) {
                            value = position;
	                    }
	                });
                }
            }
            
            Label {
                id: seekerLabel
                property string positionText
                property string durationText
                text: qsTr("[ %1 / %2 ]").arg(positionText).arg(durationText)
                textStyle.fontSize: FontSize.XSmall
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                verticalAlignment: VerticalAlignment.Bottom
                
                onCreationCompleted: {
                    player.durationChanged.connect( function(duration) {
                        durationText = textUtils.formatTime(duration);
                    });
                
	                player.positionChanged.connect( function(position) {
	                    positionText = textUtils.formatTime(position);
	                });
                }
            }
        }
    }
    
    Container
    {
        topPadding: 40
        horizontalAlignment: HorizontalAlignment.Center
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        ControlButton {
            defaultImageSource: "images/ic_prev.png"
            
            onClicked: {
                player.skip(-1);
            }
        }
        
        ControlButton {
            defaultImageSource: "images/ic_rewind.png"
            
            onClicked: {
                jumpTimer.count -= 1;
                timer.refresh();
            }
        }
        
        ControlButton {
            defaultImageSource: player.playing ? "images/ic_pause.png" : "images/ic_play.png"

            shortcuts: [
                Shortcut {
                    key: SystemShortcuts.ScrollDownOneScreen
                }
            ]
            
            onClicked: {
                player.togglePlayback();
            }
        }
        
        ControlButton {
            defaultImageSource: "images/ic_forward.png"
            
            onClicked: {
                jumpTimer.count += 1;
                timer.refresh();
            }
        }
        
        ControlButton {
            defaultImageSource: "images/ic_next.png"
            
            onClicked: {
                player.skip(1);
            }
        }
    }
    
    onCreationCompleted: {
        fadeIn.play();
        timer.refresh();
    }
    
    animations: [
        FadeTransition {
            id: fadeIn
            fromOpacity: 0
            toOpacity: 1
            duration: 500
            
            onStarted: {
                page.titleBar.visibility = page.actionBarVisibility = ChromeVisibility.Overlay;
                root.visible = true;
            }
            
            onEnded: {
                timer.refresh();
            }
        },
        
        FadeTransition {
            id: fadeOut
            fromOpacity: 1
            toOpacity: 0
            duration: 500
            
            onEnded: {
                root.visible = false;
                page.titleBar.visibility = page.actionBarVisibility = ChromeVisibility.Hidden;
            }
        }
    ]
    
    attachedObjects: [
        TextUtils {
            id: textUtils
        },

        MediaKeyWatcher {
            id: keyWatcher
            key: MediaKey.PlayPause
            property variant lastClick
            
            onShortPress: {
                var now = new Date();
                
                if (now-lastClick < 500) {
                    bookmarkTimer.stop();
                    testSheet.open();
                } else {
                    bookmarkTimer.start(500);
                }
                
                lastClick = now;
            }
        },
        
        TestSheet {
            id: testSheet
        },
        
        QTimer {
            id: timer
            singleShot: true
            
            onTimeout: {
                fadeOut.play();
            }
            
            function refresh() {
                start(5000);
            }
        },
        
        QTimer {
            id: jumpTimer
            property int count
            singleShot: true
            
            onCountChanged: {
                if (count != 0) {
                    start(250);
                }
            }
            
            onTimeout: {
                if (count != 0) {
                    player.jump(count*10000);
                    count = 0;
                }
            }
        },
        
        QTimer {
            id: bookmarkTimer
            singleShot: true
            
            onTimeout: {
                player.togglePlayback();
            }
        }
    ]
}