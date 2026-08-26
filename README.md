# Alfie Native iOS Application 

This is a repository for an e-commerce iOS app template. Its current behavior can be seen in the following demonstration:

https://github.com/user-attachments/assets/864d30fa-7172-4900-94d0-ee928192b793

---

## Prerequisites

1. This project contains sensitive files encrypted using `git-secret`. Before starting, you must decrypt them locally to build the project. To do this, request the **public and private GPG keys** from the team. See [this section](#sensitive-files) for details.
2. This project fetches data from the **Alfie-BFF** GraphQL API, run locally on `localhost:3000`. See [`Docs/GraphQL.md`](Docs/GraphQL.md) for the local loop.

## Architecture

MVVM with flow-based navigation, in Swift Package modules under `Alfie/AlfieKit/`. Each feature
module owns its Views, ViewModels, DependencyContainers and Navigation (FlowViewModel + Route).

See [`Docs/Architecture.md`](Docs/Architecture.md) for the layer-by-layer patterns, the module
graph, and the service/dependency-injection rules.

---

## Sensitive files 

When working in a shared repository, security measures are essential—especially if the repository is public.

If a file containing sensitive data must be stored in the repository, it should be **encrypted**. For this, we use `git-secret`, specification can be found [here](https://sobolevn.me/git-secret/#using-gpg).

### Setting Up the Project

A **GPG key pair** was created for the team, along with a separate pair for CI/CD. To decrypt secrets, you need to:

1. Install project dependencies (`git-secret`and `gnupg` which is a `git-secret` dependency, if not already installed).
2. Import both the **public and private keys** locally.

**Steps**

```
# Install project dependencies
brew bundle install

# Check if `git-secret` is installed
git-secret --version

# If it's not installed, install it
brew install git-secret

# Check if `gnupg` is installed
gpg --version

# If it's not installed, install it
brew install gnupg

# Import the public key (needed to encrypt secrets)
gpg --import public-key-path.gpg

# Import the private key (needed to decrypt secrets)
gpg --import private-key-path.gpg

# Reveal the decrypted files
git secret reveal
```

After running `git secret reveal`, it may seem like nothing happened. However, the decrypted files are **automatically ignored** by Git via `.gitignore`, preventing accidental commits.

To verify which files were revealed, check `.gitsecret/paths/mapping.cfg`. This file maintains a list of all encrypted files.

### Adding a New Sensitive File

To encrypt a new file:

1. Add it **only locally** (do not commit it yet).
2. Register it as a secret.
3. Encrypt it.

```
# Ensure the file is only local and not tracked by Git
git rm --cached path-to-the-sensitive-file

# Add it to the secrets list
git secret add path-to-the-sensitive-file

# Encrypt the sensitive file
git secret hide
```

Before committing, confirm that:

1. The **unencrypted file is not committed**.
2. Only the `.secret` version of the file is included in the commit.

By default, `git-secret` adds the sensitive file to `.gitignore`, but **double-check** to ensure it's excluded from commits.

---

## Localisation

This project uses [Apple String Catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog). It requires iOS 16 which brings a new way to localise strings with `LocalizedStringResource`. 

It is possible to initialise a localised string or a localised attributed string from a `LocalizedStringResource` beforehand or keep it to localise later when needed. The later approach enables having dynamic localisation on SwiftUI Previews by injecting different environment locales, while initialising a localised string/attributed string beforehand disables the ability to automatic lookup for a localisable resource in a different language.

In this project is being used [SwiftGen](https://github.com/SwiftGen/SwiftGen) which generates strongly-typed accessors for string catalogues, providing several significant benefits. First and foremost, it eliminates the risk of runtime errors caused by typos or incorrect key usage in localized strings, as all keys are now referenced through a type-safe API. This ensures compile-time validation, meaning that if a string key is removed or changed, the compiler will catch the issue immediately, reducing the likelihood of bugs slipping into production. Additionally, the generated enums provide a clear and organized structure, making it easier for developers to find and use localized strings consistently across the app. This approach also enhances code readability and maintainability, as the usage of localized strings is self-documenting and less prone to human error. Overall, it streamlines the development process, improves localization reliability, and boosts developer confidence.

#### How to use

1. Open the String Catalog table `L10n`.
2. **Manually** add the entries in the base language and any other languages. Please use `ReverseDomain` convention along with `SnakeCase` convention for keys naming (ex: `plp.error_view.title`) and give translation keys meaningful names.
3. *Mark for Review* any entry not officially provided/approved to easily track the translations state (*Mark as Reviewed* when this happens too)
4. Build the project. Using [SwiftGen](https://github.com/SwiftGen/SwiftGen), will automatically update the `L10n+Generated.swift` file.

**Note:** New tables are discouraged, the goal is to have everything in the `L10n` table.

**Sample**

```
// L10n+Generated.swift
enum L10n {
  enum Account {
    /// Account
    static let title = L10n.tr("L10n", "account.title")
  }
  enum Home {
    /// Home
    static let title = L10n.tr("L10n", "home.title")
    enum LoggedIn {
      /// Member Since: %@
      static func subtitle(_ p1: Any) -> String {
        return L10n.tr("L10n", "home.logged_in.subtitle", String(describing: p1))
      }
      /// Hi, %@
      static func title(_ p1: Any) -> String {
        return L10n.tr("L10n", "home.logged_in.title", String(describing: p1))
      }
    }
  }    
}

...SwiftUI...
Text(L10n.Account.title)
Text(L10n.Home.LoggedIn.title("Title"))

```

#### How to test

**LocalizationTests** contains some tests that already handle the supported languages.
If for some specific reason you have created a new table, you should include in **testLocalizationTables** test that will go through all the keys and validate translations are in place for all supported languages.
Regarding testing localisation with arguments it's recommended to create a test to validate each variation (pluralization, devices, etc.) you may need to customize.

For example for the key **plp.number_of_results.message** below with pluralization, a test **testLocalizableProductListingResultsWithArgs** could be designed to lookup for each variation:

- **One**: %d result
- **Other**: %d results

```
func testLocalizableProductListingResultsWithArgs() {
  localizations.forEach { localization in
    let resources = [0, 1, 2].map { L10n.Plp.NumberOfResults.message($0) }
    XCTAssertTrue(validateLocalizedStrings(resources, for: localization))
  }
}
```

#### Why SwiftGenPlugin?

This project utilizes [SwiftGenPlugin](https://github.com/SwiftGen/SwiftGenPlugin) to streamline the integration of [SwiftGen](https://github.com/SwiftGen/SwiftGen) into our workflow. By leveraging SwiftGenPlugin, we can manage the SwiftGen dependency directly through Swift Package Manager (SPM), avoiding the need to install the SwiftGen binary locally or rely on Cocoapods for dependency management. This approach ensures a cleaner, more organized setup for integrating SwiftGen, simplifies dependency handling, and makes the project easier to maintain and share across teams.

#### SwiftGen & SwiftGenPlugin notes

Both dependencies currently rely on forks of the original repositories, as the original projects appear to be abandoned. The solution for supporting string catalogues is still pending merge in a long-standing pull request ([PR link](https://github.com/SwiftGen/SwiftGen/pull/1124)).

The SwiftGenPlugin leverages Swift Package Manager (SPM) plugins by providing both a build tool plugin and a command plugin. While both plugins serve the same purpose of generating type-safe files, there are key differences:

The build tool plugin does not have write permissions, restricting the generated `L10n+Generated.swift` file to the `DerivedData` folder.
The command plugin allows generating the `L10n+Generated.swift` file directly in the desired location, but it must be run manually with the command:
`swift package --allow-writing-to-package-directory generate-code-for-resources`.
Given these constraints, we opted for the command plugin. It is integrated into a build phase under the `Run Build Tool Plug-ins` section, where it generates a `L10n+generated.swift` file in `SharedUI` library. To address this, a custom build phase script, `Run SwiftGen`, is used to run the command `swift package --allow-writing-to-package-directory generate-code-for-resources --config swiftgen.yml`. 

For more information about SPM plugins, see the official [documentation](https://github.com/swiftlang/swift-package-manager/blob/main/Documentation/Plugins.md).

---

## GraphQL

This project uses GraphQL to fetch data from the BFF API. The schema is **owned by the BFF** and synced into this repo (committed at `Alfie/AlfieKit/Sources/BFFGraph/CodeGen/Schema/schema.graphqls`), so codegen and builds stay self-contained.

For the BFF integration workflow, see [`Docs/GraphQL.md`](Docs/GraphQL.md):

- **Running the app against a local BFF** — starting the BFF, pointing the app at it
- **Syncing the BFF schema** — `Alfie/scripts/sync-bff-schema.sh`
- **Adding / updating queries** — query, fragment, and converter patterns

---

## CI/CD

**Work in progress**

---

## Release

**Work in progress**

---
