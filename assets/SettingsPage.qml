import bb.cascades 1.0

Page
{
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            SettingPair
            {
                title: qsTr("Landscape Lock") + Retranslate.onLanguageChanged
                key: "landscape"
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The app will be locked to the landscape orientation.")
                    } else {
                        infoText.text = qsTr("The app will not be locked to just the landscape orientation.")
                    }
                }
            }
            
            SettingPair {
                topMargin: 20;
                title: qsTr("Stretch Video") + Retranslate.onLanguageChanged
                key: "stretch"
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The video will be stretched to fill the entire screen.")
                    } else {
                        infoText.text = qsTr("The video will not be stretched to fill the entire screen.")
                    }
                }
            }
            
            SettingPair {
                topMargin: 20;
                bottomPadding: 40
                title: qsTr("Activate Bluetooth") + Retranslate.onLanguageChanged
                key: "bluetooth"
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The Bluetooth radio will automatically activated on app launch.")
                    } else {
                        infoText.text = qsTr("The Bluetooth radio will not be modified.")
                    }
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
}