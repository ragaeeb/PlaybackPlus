import bb.cascades 1.0
import com.canadainc.data 1.0

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
                horizontalAlignment: HorizontalAlignment.Fill
                
                onTouch: {
                    if ( event.isUp() ) {
                        player.seek(immediateValue);
                        timer.start(5000);
                    } else if ( event.isMove() ) {
                        seekerLabel.positionText = textUtils.formatTime(immediateValue);
                    } else if ( event.isDown() ) {
                        timer.stop();
                    }
                }
                
                onCreationCompleted: {
                    player.durationChanged.connect( function(duration) {
                            toValue = duration;
                    });
                
                player.positionChanged.connect( function(position) {
                        value = position;
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
                console.log("SKIPPING TO PREVIOUS!!!!!!!!!");
                player.skip(-1);
            }
        }
        
        ControlButton {
            defaultImageSource: "images/ic_rewind.png"
            
            onClicked: {
                player.jump(-10000);
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
                player.jump(10000);
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
        timer.start(5000);
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
                timer.start(5000);
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
        
        QTimer {
            id: timer
            singleShot: true
            
            onTimeout: {
                fadeOut.play();
            }
        }
    ]
}