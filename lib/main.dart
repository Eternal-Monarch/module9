import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Recipe {
  final String title;
  final String description;
  final List<String> ingredients;
  final String? photo;

  Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    this.photo,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      photo: json['photo'],
    );
  }
}

class MyApp extends StatelessWidget {
  final String jsonString = '''
    {
      "recipes": [
        {
          "title": "Pasta Carbonara",
          "description": "Creamy pasta dish with bacon and cheese.",
          "ingredients": ["spaghetti", "bacon", "egg", "cheese"],
          "photo": "images/pasta.jpg"
        },
        {
          "title": "Caprese Salad",
          "description": "Simple and refreshing salad with tomatoes, mozzarella, and basil.",
          "ingredients": ["tomatoes", "mozzarella", "basil"]
        },
        // Add more recipes here
      ]
    }
  ''';

  List<Recipe> parseRecipes(String responseBody) {
    final parsed = json.decode(responseBody);
    final recipes = parsed['recipes'].cast<Map<String, dynamic>>();
    return recipes.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<Recipe>> fetchRecipes() async {
    // Simulating API request with delay
    await Future.delayed(Duration(seconds: 2));

    // Replace this line with your actual API request
    // final response = await http.get(Uri.parse('YOUR_JSON_URL'));

    // Simulating parsing JSON response
    final response = http.Response(jsonString, 200);

    if (response.statusCode == 200) {
      return parseRecipes(response.body);
    } else {
      throw Exception('Failed to fetch recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Recipe App'),
        ),
        body: FutureBuilder<List<Recipe>>(
          future: fetchRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final recipes = snapshot.data!;
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    leading: recipe.photo != null
                        ? Image.asset(
                      recipe.photo!,
                      width: 48,
                      height: 48,
                    )
                        : Icon(Icons.image_not_supported),
                    title: Text(recipe.title),
                    subtitle: Text(recipe.description),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement recipe details screen navigation
                    },
                  );
                },
              );
            } else {
              return Center(child: Text('No recipes found'));
            }
          },
        ),
      ),
    );
  }
}
