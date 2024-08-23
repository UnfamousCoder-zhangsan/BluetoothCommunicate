//
//  AccBluetoothCommunicate.h
//  AccBluetoothCommunicate
//
//  Created by hi kobe on 2024/3/27.
//

#import <Foundation/Foundation.h>

//! Project version number for AccBluetoothCommunicate.
FOUNDATION_EXPORT double AccBluetoothCommunicateVersionNumber;

//! Project version string for AccBluetoothCommunicate.
FOUNDATION_EXPORT const unsigned char AccBluetoothCommunicateVersionString[];

#if __has_include("AccBCCommandTaskManager.h")
#import "AccBCCommandTaskManager.h"
#endif
#if __has_include("BabyBluetooth.h")
#import "BabyBluetooth.h"
#endif
#if __has_include("CommandTaskProtocol.h")
#import "CommandTaskProtocol.h"
#endif
