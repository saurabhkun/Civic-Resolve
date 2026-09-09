#!/usr/bin/env python3
"""
CivicResolve App Icon Generator

This script generates app icons that match the splash screen design:
- Icons.location_city_rounded (city/buildings icon)
- Color: #667EEA (purple-blue)
- White circular background
- Multiple sizes for different platforms
"""

import os
from PIL import Image, ImageDraw
import math

def create_city_icon(size, color="#667EEA", bg_color="white"):
    """Create a city/buildings icon similar to Icons.location_city_rounded"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Convert hex color to RGB
    if color.startswith('#'):
        color = color[1:]
    r, g, b = tuple(int(color[i:i+2], 16) for i in (0, 2, 4))
    icon_color = (r, g, b, 255)
    
    # Background circle
    if bg_color == "white":
        bg_color = (255, 255, 255, 255)
    
    # Draw background circle
    margin = size * 0.05  # 5% margin
    circle_size = size - (2 * margin)
    draw.ellipse([margin, margin, margin + circle_size, margin + circle_size], 
                 fill=bg_color)
    
    # Calculate icon area (70% of circle)
    icon_area = circle_size * 0.7
    icon_start = (size - icon_area) / 2
    
    # Draw city buildings (simplified version of Icons.location_city_rounded)
    building_width = icon_area / 6
    
    # Building 1 (tallest, left)
    b1_height = icon_area * 0.7
    b1_x = icon_start + building_width * 0.5
    b1_y = icon_start + icon_area - b1_height
    draw.rectangle([b1_x, b1_y, b1_x + building_width, icon_start + icon_area], 
                   fill=icon_color)
    
    # Building 2 (medium, center)
    b2_height = icon_area * 0.5
    b2_x = icon_start + building_width * 2
    b2_y = icon_start + icon_area - b2_height
    draw.rectangle([b2_x, b2_y, b2_x + building_width, icon_start + icon_area], 
                   fill=icon_color)
    
    # Building 3 (tallest, center-right)
    b3_height = icon_area * 0.8
    b3_x = icon_start + building_width * 3.5
    b3_y = icon_start + icon_area - b3_height
    draw.rectangle([b3_x, b3_y, b3_x + building_width, icon_start + icon_area], 
                   fill=icon_color)
    
    # Building 4 (short, right)
    b4_height = icon_area * 0.4
    b4_x = icon_start + building_width * 5
    b4_y = icon_start + icon_area - b4_height
    draw.rectangle([b4_x, b4_y, b4_x + building_width, icon_start + icon_area], 
                   fill=icon_color)
    
    # Add windows to buildings
    window_size = building_width * 0.15
    window_spacing = building_width * 0.25
    
    # Windows for each building
    buildings = [
        (b1_x, b1_y, building_width, b1_height),
        (b2_x, b2_y, building_width, b2_height),
        (b3_x, b3_y, building_width, b3_height),
        (b4_x, b4_y, building_width, b4_height)
    ]
    
    for bx, by, bw, bh in buildings:
        # Add 2-3 rows of windows
        rows = max(2, int(bh / (window_size * 2)))
        for row in range(rows):
            y_pos = by + (bh / rows) * row + window_spacing
            if y_pos + window_size < by + bh - window_spacing:
                # Two windows per row
                x1 = bx + window_spacing
                x2 = bx + bw - window_spacing - window_size
                draw.rectangle([x1, y_pos, x1 + window_size, y_pos + window_size], 
                             fill=bg_color)
                draw.rectangle([x2, y_pos, x2 + window_size, y_pos + window_size], 
                             fill=bg_color)
    
    return img

def generate_android_icons():
    """Generate Android app icons in all required sizes"""
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    base_path = "android/app/src/main/res"
    
    for folder, size in android_sizes.items():
        folder_path = os.path.join(base_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        icon = create_city_icon(size)
        icon_path = os.path.join(folder_path, "ic_launcher.png")
        icon.save(icon_path, "PNG")
        print(f"Generated Android icon: {icon_path}")

def generate_ios_icons():
    """Generate iOS app icons in all required sizes"""
    ios_sizes = [
        (20, "Icon-App-20x20@1x.png"),
        (40, "Icon-App-20x20@2x.png"),
        (60, "Icon-App-20x20@3x.png"),
        (29, "Icon-App-29x29@1x.png"),
        (58, "Icon-App-29x29@2x.png"),
        (87, "Icon-App-29x29@3x.png"),
        (40, "Icon-App-40x40@1x.png"),
        (80, "Icon-App-40x40@2x.png"),
        (120, "Icon-App-40x40@3x.png"),
        (60, "Icon-App-60x60@2x.png"),
        (120, "Icon-App-60x60@2x.png"),
        (180, "Icon-App-60x60@3x.png"),
        (76, "Icon-App-76x76@1x.png"),
        (152, "Icon-App-76x76@2x.png"),
        (167, "Icon-App-83.5x83.5@2x.png"),
        (1024, "Icon-App-1024x1024@1x.png")
    ]
    
    ios_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_path, exist_ok=True)
    
    for size, filename in ios_sizes:
        icon = create_city_icon(size)
        icon_path = os.path.join(ios_path, filename)
        icon.save(icon_path, "PNG")
        print(f"Generated iOS icon: {icon_path}")

def generate_web_icons():
    """Generate web app icons"""
    web_sizes = [
        (16, "favicon.png"),
        (192, "icons/Icon-192.png"),
        (512, "icons/Icon-512.png"),
        (192, "icons/Icon-maskable-192.png"),
        (512, "icons/Icon-maskable-512.png")
    ]
    
    web_path = "web"
    icons_path = os.path.join(web_path, "icons")
    os.makedirs(icons_path, exist_ok=True)
    
    for size, filename in web_sizes:
        icon = create_city_icon(size)
        icon_path = os.path.join(web_path, filename)
        icon.save(icon_path, "PNG")
        print(f"Generated web icon: {icon_path}")

def generate_macos_icons():
    """Generate macOS app icons"""
    macos_sizes = [
        (16, "app_icon_16.png"),
        (32, "app_icon_32.png"),
        (64, "app_icon_64.png"),
        (128, "app_icon_128.png"),
        (256, "app_icon_256.png"),
        (512, "app_icon_512.png"),
        (1024, "app_icon_1024.png")
    ]
    
    macos_path = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(macos_path, exist_ok=True)
    
    for size, filename in macos_sizes:
        icon = create_city_icon(size)
        icon_path = os.path.join(macos_path, filename)
        icon.save(icon_path, "PNG")
        print(f"Generated macOS icon: {icon_path}")

def generate_windows_icon():
    """Generate Windows app icon"""
    windows_path = "windows/runner/resources"
    os.makedirs(windows_path, exist_ok=True)
    
    # Generate ICO file with multiple sizes
    sizes = [16, 32, 48, 64, 128, 256]
    images = []
    
    for size in sizes:
        icon = create_city_icon(size)
        images.append(icon)
    
    ico_path = os.path.join(windows_path, "app_icon.ico")
    images[0].save(ico_path, format='ICO', sizes=[(img.width, img.height) for img in images])
    print(f"Generated Windows icon: {ico_path}")

def main():
    """Generate all app icons"""
    print("🏗️  Generating CivicResolve app icons...")
    print("📱 Matching splash screen design: Icons.location_city_rounded")
    print("🎨 Color: #667EEA with white circular background")
    print()
    
    try:
        generate_android_icons()
        print()
        generate_ios_icons()
        print()
        generate_web_icons()
        print()
        generate_macos_icons()
        print()
        generate_windows_icon()
        print()
        print("✅ All CivicResolve app icons generated successfully!")
        print("🔄 The new icons will appear when you build and install the app.")
        
    except Exception as e:
        print(f"❌ Error generating icons: {e}")
        print("Make sure you have Pillow installed: pip install Pillow")

if __name__ == "__main__":
    main()