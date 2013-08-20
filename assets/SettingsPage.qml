import bb.cascades 1.0

BasePage
{
    contentContainer: Container
    {
        leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
        
        SettingPair
        {
            title: qsTr("Landscape Lock") + Retranslate.onLanguageChanged
        	key: "landscape" == 1
    
            toggle.onCheckedChanged: {
        		if (checked) {
        		    infoText.text = qsTr("The app will be locked to the landscape orientation.")
        		    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.DisplayLandscape
        		} else {
        		    infoText.text = qsTr("The app will not be locked to just the landscape orientation.")
        		    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All
        		}
            }
        }
        
        SettingPair {
            topMargin: 20
            title: qsTr("Stretch Video") + Retranslate.onLanguageChanged
        	key: "stretch"
    
            toggle.onCheckedChanged: {
        		if (checked) {
        		    infoText.text = qsTr("The video will be stretched to fill the entire screen.")
        		} else {
        		    infoText.text = qsTr("The video will not be stretched to fill the entire screen.")
        		}
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        Label {
            id: infoText
            multiline: true
            textStyle.fontSize: FontSize.XXSmall
            textStyle.textAlign: TextAlign.Center
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Center
        }
    }
}