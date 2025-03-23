import ProjectDescription

// MARK: - Project

let project = tuistProject()

func tuistProject() -> Project {

	let appName = "Nervespace"
	let bundleID = "com.slips.nervespace"
	let osVersion = "17.0"

	let destinations: ProjectDescription.Destinations = [
		.iPhone,
		.iPad,
		.macWithiPadDesign,
		.appleVisionWithiPadDesign,
	]

	var projectTargets: [Target] = []
	var projectPackages: [Package] = []
	var appDependencies: [TargetDependency] = []
	var appResources: [ResourceFileElement] = ["Targets/App/Resources/**"]
	var appEntitlements: [String: Plist.Value] = [:]
	var appInfoPlist: [String: Plist.Value] = [
		"CFBundleShortVersionString": "$(MARKETING_VERSION)",
		"CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
		"NSFaceIDUsageDescription": "We will use FaceID to authenticate you",
		"NSCameraUsageDescription": "We need Camera Access for the App to work.",
		"NSLocationAlwaysAndWhenInUseUsageDescription": "We need Location Access for the App to work.",
		"NSLocationWhenInUseUsageDescription": "We need Location Access for the App to work.",
		"NSContactsUsageDescription": "We need Contacts Access for the App to work.",
		"NSMicrophoneUsageDescription": "We need Microhone Access for the App to work.",
		"NSCalendarsFullAccessUsageDescription": "We need Calendar Access for the App to work.",
		"NSRemindersFullAccessUsageDescription": "We need Reminders Access for the App to work.",
		"NSPhotoLibraryUsageDescription": "We need Photo Library Access for the App to work.",
		"UILaunchStoryboardName": "LaunchScreen",
		"UISupportedInterfaceOrientations": .array(["UIInterfaceOrientationPortrait"]),  //Only Support Portrait on iphone
	]

	let sharedKit = TargetDependency.target(name: "SharedKit")

	addSharedKit()
	addNotifKit()
	addSupabaseKit()

	addApp()

	return Project(
		name: appName,
		options: .options(
			disableSynthesizedResourceAccessors: true,
			textSettings: .textSettings(
				usesTabs: false,
				indentWidth: 4,
				tabWidth: 4,
				wrapsLines: true
			)
		),
		packages: projectPackages,
		settings: .settings(base: [
			"ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES": "AppIcon-Alt-1 AppIcon-Alt-2",
			"ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS": "YES",
			"MARKETING_VERSION": "1.0.0",
			"CURRENT_PROJECT_VERSION": "1",
		]),
		targets: projectTargets
	)

	func addApp() {
		let mainTarget: Target = .target(
			name: appName,
			destinations: destinations,
			product: .app,
			bundleId: bundleID,
			deploymentTargets: .iOS(osVersion),
			infoPlist: .extendingDefault(with: appInfoPlist),
			sources: ["Targets/App/Sources/**"],
			resources: .resources(appResources),
			entitlements: .dictionary(appEntitlements),
			scripts: [],
			dependencies: appDependencies,
			settings: .settings(base: [
				"OTHER_LDFLAGS": "-ObjC",
				"ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",

			])
		)

		projectTargets.append(mainTarget)
	}

	// Code Shared Across all targets
	func addSharedKit() {
		let targetName = "SharedKit"
		let sharedTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: ["Targets/\(targetName)/Resources/**"],
			dependencies: []
		)

		appDependencies.append(sharedKit)
		projectTargets.append(sharedTarget)
	}

	func addNotifKit() {
		let notifTargetName = "NotifKit"
		let notifTarget: Target = .target(
			name: notifTargetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(notifTargetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(notifTargetName)/Sources/**"],
			resources: [],
			dependencies: [
				sharedKit,
				TargetDependency.package(product: "OneSignalFramework", type: .runtime),
			])

		appDependencies.append(TargetDependency.target(name: notifTargetName))

		// Also have to include that, otherwise the app crashes
		appDependencies.append(TargetDependency.package(product: "OneSignalFramework", type: .runtime))
		appResources.append("Targets/\(notifTargetName)/Config/OneSignal-Info.plist")

		appInfoPlist["UIBackgroundModes"] = .array(["remote-notification"])

		projectPackages.append(
			.remote(
				url: "https://github.com/OneSignal/OneSignal-iOS-SDK.git",
				requirement: .upToNextMajor(from: "5.2.7")
			)
		)
		projectTargets.append(notifTarget)
		let notifExtensionTargetName = "OneSignalNotificationServiceExtension"
		let notifExtensionTarget: Target = .target(
			name: notifExtensionTargetName,
			destinations: .iOS,
			product: .appExtension,
			bundleId: "\(bundleID).\(notifExtensionTargetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .dictionary([
				"NSExtension": [
					"NSExtensionPointIdentifier": "com.apple.usernotifications.service",
					"NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService",
				]
			]),
			sources: ["Targets/\(notifTargetName)/\(notifExtensionTargetName)/**"],
			entitlements:
				Entitlements
				.dictionary(
					[
						"com.apple.security.application-groups": .array(["group.\(bundleID).onesignal"])
					]
				),
			dependencies: [TargetDependency.package(product: "OneSignalExtension", type: .runtime)]
		)
		appEntitlements["aps-environment"] = .string("development")
		appEntitlements["com.apple.security.application-groups"] = .array(["group.\(bundleID).onesignal"])
		projectTargets.append(notifExtensionTarget)
	}

	// Supabase Auth + DB
	@discardableResult
	func addSupabaseKit() -> TargetDependency {
		let targetName = "SupabaseKit"
		let supabaseTarget: Target = .target(
			name: targetName,
			destinations: destinations,
			product: .framework,
			bundleId: "\(bundleID).\(targetName)",
			deploymentTargets: .iOS(osVersion),
			infoPlist: .default,
			sources: ["Targets/\(targetName)/Sources/**"],
			resources: [],
			dependencies: [
				TargetDependency.package(product: "Supabase", type: .runtime),
				sharedKit,
			]
		)
		let targetDependency = TargetDependency.target(name: targetName)
		appDependencies.append(targetDependency)
		projectPackages
			.append(
				.remote(
					url: "https://github.com/supabase-community/supabase-swift.git",
					requirement: .upToNextMajor(from: "2.20.5")
				)
			)
		projectTargets.append(supabaseTarget)
		appEntitlements["com.apple.developer.applesignin"] = .array(["Default"])  // Sign in with Apple Capability
		appResources.append("Targets/\(targetName)/Config/Supabase-Info.plist")
		return targetDependency

	}
}
