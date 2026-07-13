import ProjectDescription

let project = makeProject()

private func makeProject() -> Project {
    let appName = "Nervespace"
    let bundleID = "com.slips.nervespace"
    let deploymentTarget = DeploymentTargets.iOS("17.0")
    let destinations: Destinations = [
        .iPhone,
        .iPad,
        .macWithiPadDesign,
        .appleVisionWithiPadDesign,
    ]

    let sharedKit = TargetDependency.target(name: "SharedKit")
    let localDataKit = TargetDependency.target(name: "LocalDataKit")

    let app = Target.target(
        name: appName,
        destinations: destinations,
        product: .app,
        bundleId: bundleID,
        deploymentTargets: deploymentTarget,
        infoPlist: .extendingDefault(with: [
            "CFBundleShortVersionString": "$(MARKETING_VERSION)",
            "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
            "CFBundleDisplayName": "Nervespace",
            "ITSAppUsesNonExemptEncryption": .boolean(false),
            "LSApplicationCategoryType": "public.app-category.healthcare-fitness",
            "UILaunchStoryboardName": "LaunchScreen",
            "UISupportedInterfaceOrientations": .array([
                "UIInterfaceOrientationPortrait",
            ]),
        ]),
        sources: ["Targets/App/Sources/**"],
        resources: ["Targets/App/Resources/**"],
        dependencies: [sharedKit, localDataKit],
        settings: .settings(base: [
            "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
        ])
    )

    let appTests = Target.target(
        name: "AppTests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleID).AppTests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        sources: ["Targets/AppTests/Tests/**"],
        dependencies: [
            .target(name: appName),
            localDataKit,
            sharedKit,
        ]
    )

    let uiTests = Target.target(
        name: "NervespaceUITests",
        destinations: [.iPhone],
        product: .uiTests,
        bundleId: "\(bundleID).NervespaceUITests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        sources: ["Targets/NervespaceUITests/Tests/**"],
        dependencies: [.target(name: appName)]
    )

    let sharedTarget = Target.target(
        name: "SharedKit",
        destinations: destinations,
        product: .framework,
        bundleId: "\(bundleID).SharedKit",
        deploymentTargets: deploymentTarget,
        sources: ["Targets/SharedKit/Sources/**"],
        resources: ["Targets/SharedKit/Resources/**"],
        dependencies: []
    )

    let sharedTests = Target.target(
        name: "SharedKitTests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleID).SharedKitTests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        sources: ["Targets/SharedKitTests/Tests/**"],
        dependencies: [sharedKit]
    )

    let localDataTarget = Target.target(
        name: "LocalDataKit",
        destinations: destinations,
        product: .framework,
        bundleId: "\(bundleID).LocalDataKit",
        deploymentTargets: deploymentTarget,
        sources: ["Targets/LocalDataKit/Sources/**"]
    )

    let localDataTests = Target.target(
        name: "LocalDataKitTests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleID).LocalDataKitTests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        sources: ["Targets/LocalDataKitTests/Tests/**"],
        dependencies: [localDataKit, sharedKit]
    )

    let stagingScheme = Scheme.scheme(
        name: "\(appName)-Staging",
        shared: true,
        hidden: false,
        buildAction: .buildAction(
            targets: ["\(appName)"],
            findImplicitDependencies: true
        ),
        testAction: .targets(
            [
                "AppTests",
                "LocalDataKitTests",
                "NervespaceUITests",
                "SharedKitTests",
            ],
            configuration: .debug
        ),
        runAction: .runAction(configuration: "Debug"),
        archiveAction: .archiveAction(configuration: "Release")
    )

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
        packages: [],
        settings: .settings(base: [
            "ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES": "AppIcon-Alt-1 AppIcon-Alt-2",
            "ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS": "YES",
            "CURRENT_PROJECT_VERSION": "1",
            "MARKETING_VERSION": "1.0.0",
        ]),
        targets: [
            app,
            appTests,
            uiTests,
            sharedTarget,
            sharedTests,
            localDataTarget,
            localDataTests,
        ],
        schemes: [stagingScheme]
    )
}
