# Shopify 🛍️

A modern iOS e-commerce app built with UIKit, MVVM architecture, and Core Data – featuring product browsing, cart management, favorites, and seamless navigation with coordinator pattern.

## 🚀 Features

### Must-Haves
- **Product Browsing**: Browse products with pagination, search, and filtering capabilities
- **Product Details**: View detailed product information with images and descriptions
- **Shopping Cart**: Add/remove items, view cart contents, and manage quantities
- **Favorites**: Save and manage favorite products with persistent storage
- **User Profile**: User account management and settings
- **Navigation**: Seamless navigation using coordinator pattern architecture

### Nice-to-Haves & Enhancements
- **Core Data Integration**: Persistent storage for cart items, favorites, and user data
- **Background Context**: Efficient Core Data operations with background context for heavy operations
- **Error Handling**: Comprehensive error management with user-friendly messages
- **Analytics & Crash Reporting**: Firebase integration for analytics and crash reporting
- **Unit Testing**: Extensive test coverage for view models, services, and data layers
- **Dependency Injection**: Clean architecture with Factory-based dependency injection
- **Modern UI**: Native UIKit components with responsive design and accessibility support
- **Network Layer**: Robust networking with protocol-based service architecture
- **Notification System**: Notification Center for app-wide event broadcasting

## 🛠️ Tech Stack

- **UIKit** (no Storyboards except LaunchScreen)
- **MVVM Architecture** with Coordinator Pattern
- **Core Data** for persistence with background context support
- **Factory** for dependency injection
- **Firebase** for analytics and crash reporting
- **Kingfisher** for image loading and caching
- **Alamofire** for network requests
- **Unit Testing** (XCTest) with comprehensive coverage
- **Protocol-oriented** service architecture
- **Error handling** with custom error types

### Architecture Principles
- **MVVM + Coordinator**: Clean separation between UI, business logic, and navigation
- **Protocol-oriented Design**: All services implement protocols for testability
- **Dependency Injection**: Factory-based DI container for service management
- **Background Context**: Core Data operations optimized with background context
- **Error Handling**: Structured error management with user-friendly messages

## 📱 How to Run

1. **Clone the repo**
   ```bash
   git clone <your-repo-url>
   cd Shopify
   ```

2. **Install dependencies**
   - Factory (via Swift Package Manager)
   - Kingfisher (via Swift Package Manager)
   - Alamofire (via Swift Package Manager)
   - Firebase (via Swift Package Manager)

3. **Open in Xcode**
   - Xcode 15+ recommended
   - Set Deployment Target iOS 16.0+

4. **Configure Firebase** (if using analytics)
   - Add `GoogleService-Info.plist` to the project
   - Ensure Firebase is properly configured in `AppDelegate.swift`

5. **Run on Simulator or Device**
   - Build and run the project
   - Test all flows: Product List → Product Detail → Cart → Favorites → Profile

## Video

https://github.com/user-attachments/assets/30776b27-6f80-415f-8ffb-0f3598f0939f

## 🖼️ Screenshots

<img src="https://github.com/user-attachments/assets/e95b69ff-c709-440b-8fda-f2a31995a5c7" width="100">
<img src="https://github.com/user-attachments/assets/246674cb-1875-499d-a226-100946e9a0b8" width="100">
<img src="https://github.com/user-attachments/assets/264d79e1-05a5-42c3-b9f5-6f42bc9c3837" width="100">
<img src="https://github.com/user-attachments/assets/a2696d3a-18f9-485e-9ff8-9714318e36b5" width="100">
<img src="https://github.com/user-attachments/assets/685883fa-5308-46f9-bdd5-c62342ced350" width="100">
<img src="https://github.com/user-attachments/assets/dbe3dad4-430f-4c59-900e-6d4e380088a7" width="100">
<img src="https://github.com/user-attachments/assets/af476abe-69d8-4b8d-9ca3-fddbed6b4370" width="100">

## 👨‍💼 Development Approach

### Task Breakdown
Every requirement is split into atomic tasks with clear Task IDs (e.g., Task-101, Task-201). Each task represents a complete, testable feature or enhancement.

### Feature Branching & PR Workflow
- New branches created for each task under `feature/` (e.g., `feature/Task-203-Product-List`)
- Atomic, isolated development with clear separation of concerns
- Each feature branch includes necessary unit tests and documentation
- **PR Process**: After task completion, a pull request is opened and merged into development branch
- **Code Review**: Each PR undergoes review before merge
- **Continuous Integration**: Automated testing on each PR
  
## 📋 Task Completion Table

| Task ID | Task Name | Status | PR Status | Description |
|---------|-----------|--------|-----------|-------------|
| Task-101 | Project Setup | ✅ Complete | ✅ Merged | Initial project structure and configuration |
| Task-201 | Managers | ✅ Complete | ✅ Merged | NetworkManager, CoreDataService, NotificationManager |
| Task-203 | Product List | ✅ Complete | ✅ Merged | Product browsing with pagination and search |
| Task-205 | Product Detail | ✅ Complete | ✅ Merged | Product detail screen with add to cart |
| Task-207 | Cart Screen | ✅ Complete | ✅ Merged | Shopping cart with quantity management |
| Task-209 | Filters Screen | ✅ Complete | ✅ Merged | Advanced filtering and search capabilities |
| Task-211 | Favorite Screen | ✅ Complete | ✅ Merged | Favorites management with persistence |
| Task-213 | Unit Test | ✅ Complete | ✅ Merged | Comprehensive test coverage |
| Task-215 | Launch Screen | ✅ Complete | ✅ Merged | App launch screen and branding |
| Task-217 | Firebase | ✅ Complete | ✅ Merged | Analytics and crash reporting integration |

### PR Workflow Summary
- **Total Tasks**: 10 completed tasks
- **PRs Opened**: 10 pull requests
- **PRs Merged**: 10 successfully merged
- **Code Reviews**: All PRs underwent review
- **Test Coverage**: Unit tests implemented for core functionality

## 📁 Project Structure

```
Shopify/
├── App/                    # App lifecycle and configuration
├── Flows/                  # Feature modules with MVVM + Coordinator
│   ├── ProductList/        # Product browsing and search
│   ├── ProductDetail/      # Product details and purchase
│   ├── Cart/              # Shopping cart management
│   ├── Favorites/         # Favorites and wishlist
│   ├── Profile/           # User profile and settings
│   └── Filter/            # Product filtering
├── Services/              # Protocol-based service layer
│   ├── Network/           # API communication (Alamofire)
│   ├── CoreData/          # Data persistence
│   ├── Product/           # Product-related services
│   └── Notification/      # Notification Center
├── Shared/                # Common components and utilities
│   ├── Coordinators/      # Navigation coordination
│   ├── Views/             # Reusable UI components
│   └── Helpers/           # Utility classes
├── Factories/             # Dependency injection
├── Utils/                 # Error handling and analytics
└── Resources/             # Assets and localization
```

## 🔧 Key Components

### Coordinators
- **AppCoordinator**: Main app navigation flow
- **TabBarCoordinator**: Tab-based navigation
- **ProductListCoordinator**: Product browsing flow
- **CartCoordinator**: Shopping cart flow
- **FavoritesCoordinator**: Favorites management
- **ProfileCoordinator**: User profile flow

### View Models
- **ProductListViewModel**: Product browsing and search logic
- **ProductDetailViewModel**: Product details and cart integration
- **CartViewModel**: Shopping cart management
- **FavoritesViewModel**: Favorites and wishlist logic
- **ProfileViewModel**: User profile management

### Services
- **NetworkManager**: API communication with Alamofire
- **CoreDataService**: Data persistence with background context
- **ProductService**: Product-related API calls
- **NotificationManager**: Notification Center

### Third-Party Libraries
- **Kingfisher**: Image loading, caching, and processing
- **Alamofire**: Network request handling and response parsing
- **Firebase**: Analytics and crash reporting

## 📊 Analytics & Monitoring

- **Firebase Analytics**: User behavior tracking and app performance
- **Crash Reporting**: Automatic crash detection and reporting
- **Custom Events**: Track user interactions and business metrics
- **Error Logging**: Structured error reporting for debugging

## 🧪 Testing

### Unit Tests
- **View Model Tests**: Business logic validation
- **Service Tests**: Network and data layer testing
- **Mock Classes**: Comprehensive mocking for isolated testing
- **Async Testing**: Proper handling of asynchronous operations

## 📝 Notes

- Built as a demonstration of modern iOS development practices
- Comprehensive unit test coverage for maintainability
- Coordinator pattern for clean navigation architecture
- Factory-based dependency injection for testability
- Firebase integration for analytics and crash reporting
- Kingfisher for optimized image loading and caching
- Alamofire for robust network communication
- Task-based development with systematic PR workflow

---

**Contact**: For demonstration purposes – contact ismail.palali.pp@gmail.com for feedback!
