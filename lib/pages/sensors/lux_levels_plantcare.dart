const String luxDataJson = '''
{
    "lux_levels": [
        {
            "range": "0-50",
            "description": "Very Low Light (Dimly lit room or heavily shaded area)",
            "suitable_plants": [
                "Snake Plant (Sansevieria)",
                "ZZ Plant"
            ],
            "tips": [
                "Avoid placing most plants in this range long-term as it is inadequate for photosynthesis.",
                "Consider supplemental lighting (e.g., grow lights)."
            ]
        },
        {
            "range": "50-200",
            "description": "Low Light (Typical in offices or rooms with small windows)",
            "suitable_plants": [
                "Spider Plant",
                "Philippine Fern",
                "Chinese Evergreen"
                
            ],
            "tips": [
                "Rotate plants to ensure even light exposure.",
                "Use sheer curtains to improve light diffusion.",
                "Avoid fertilizing excessively, as low-light plants grow more slowly.",
                "Gradually introduce plants to higher light levels if their growth stagnates."
            ]
        },
        {
            "range": "200-500",
            "description": "Moderate Light (Well-lit indoor space with indirect sunlight)",
            "suitable_plants": [
                "Ferns",
                "Dracaena",
                "Philodendron"
            ],
            "tips": [
                "Best for foliage plants. Avoid direct sunlight to prevent leaf scorching.",
                "Water moderately and ensure pots have proper drainage.",
                "Group plants together to create a microenvironment with consistent humidity.",
                "Prune dead leaves to encourage healthy new growth.",
                "Rotate pots to maintain balanced and symmetrical plant shapes."
            ]
        },
        {
            "range": "500-1000",
            "description": "Bright Indirect Light (Near a window with filtered sunlight or light curtains)",
            "suitable_plants": [
                "Monstera",
                "Fiddle Leaf Fig",
                "Orchids"
            ],
            "tips": [
                "Ideal for flowering plants needing moderate light.",
                "Fertilize every 1–2 months during the growing season to support active growth.",
                "Clean leaves regularly to maximize light absorption.",
                "Create a schedule for rotating plants to promote even exposure to light."
            ]
        },
        {
            "range": "1000-10000",
            "description": "Full Sunlight (Outdoors in shaded or semi-shaded areas)",
            "suitable_plants": [
                "Herbs",
                "Succulents",
                "Citrus Trees"
            ],
            "tips": [
                "Water early in the morning to prevent water loss through evaporation.",
                "Mulch soil to retain moisture and reduce water needs.",
                "Use shades to reduce heat stress in tropical regions.",
                "Inspect leaves regularly for signs of sunburn, like brown or bleached spots."
            ]
        },
        {
            "range": "10000-100000",
            "description": "Direct Sunlight (Outdoors in full sunlight, ideal for sun-loving plants)",
            "suitable_plants": [
                "Sunflowers",
                "Lavender",
                "Roses"
            ],
            "tips": [
                "Water frequently to counteract heat stress.",
                "Protect young plants from scorching by acclimating them gradually.",
                "Apply organic fertilizers to support vigorous growth in sunny conditions.",
                "Mist leaves occasionally to increase humidity if the air is very dry."
            ]
        }
    ]
}
''';
