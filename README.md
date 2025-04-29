# Tripify

Tripify is an AI-powered Flutter application designed by **Lim Weng Ni** and **Tan Wei Siang** to simplify travel planning through a content-based recommendation system and an intelligent travel assistant. Developed using Flutter and Dart, with Python AI integration via Ollama, the app generates personalized itineraries based on user preferences such as destination and travel dates. Users can manage their profiles, create and share posts, store documents, and collaborate with friends on trip planning. The AI assistant offers general travel tips and personalized advice, even allowing users to upload itineraries for further guidance. The app streamlines the selection of destinations, activities, accommodations, and transportation, improving planning efficiency. Testing focused on the relevance of recommendations, UI responsiveness, and AI interaction quality. Future improvements include expanding the travel recommendation database and adding offline access features for greater convenience.

## Getting Started

To get started with the Tripify project, you’ll need to have the following tools installed on your system:

### Prerequisites

1. **Flutter**  
   Tripify is built using Flutter, which is used for developing cross-platform mobile applications. Follow the instructions to install Flutter:

   - [Install Flutter](https://docs.flutter.dev/get-started/install)

2. **Ollama**  
   Ollama is used to power the AI-driven recommendation system in Tripify. Install Ollama from:

   - [Download Ollama](https://ollama.com/)

3. **Dart**  
   Dart is the programming language used for Flutter applications. You can install Dart by following this guide:

   - [Install Dart](https://dart.dev/get-dart)

4. **Firebase**  
   Firebase is integrated for user authentication, database management, and real-time updates. Set up Firebase for your project by following the steps here:

   - [Firebase Setup for Flutter](https://firebase.google.com/docs/flutter/setup)

### Installation Steps

1. Clone this repository:
    ```bash
    git clone https://github.com/limwengni/tripify.git
    ```

2. Navigate to the project directory:
    ```bash
    cd tripify
    ```

3. Install dependencies:
    ```bash
    flutter pub get
    ```

4. Set up Firebase:
   - Create a Firebase project and follow the setup guide for Flutter to add your Firebase configuration.

5. Run the application:
    ```bash
    flutter run
    ```

### Features

- **Customizable and Collaborative Itineraries**: Tripify allows users to create and manage personalized itineraries based on their preferences. Users can manually select places, set dates, organize activities, and invite friends to collaborate on trip planning in real-time.
- **Content-Based Recommendation System**: Tripify recommends posts that match the user's liked hashtags, helping users discover relevant travel content based on their interests.
- **AI Travel Assistant**: Integrated with Ollama, the AI assistant offers general travel tips, answers user queries, and provides advice based on uploaded itineraries.
- **Post Management and Document Repository**: Users can create posts to share travel experiences and upload important travel documents securely within the app.

## Documentation

For more detailed information on the technologies used in Tripify, check out the following resources:

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

