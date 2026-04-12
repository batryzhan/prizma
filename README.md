# ⚔️ Guild-Learn: Cyberpunk Social Hub for Knowledge

## 🌐 Overview
**Guild-Learn** is a brutalist, cyberpunk-minimalist social platform designed for students to exchange knowledge and help each other. Built as a high-performance **Single Page Application (SPA)** using pure Vanilla technologies, it rewards helpfulness with "Utility Score" and Energy.

> "Knowledge is the only currency that matters in the sprawl."

## 🚀 Technical Stack
- **Core**: HTML5, Vanilla JavaScript (ES6+ Modules)
- **Styling**: CSS3 (Modern Flexbox/Grid, Custom Variables)
- **Architecture**: Single Page Application (SPA) with custom State Management
- **Persistence**: Browser `localStorage`
- **Design**: Cyberpunk-Minimalism (Dark Mode, Neon Accents, Zero Border Radius)

## ✨ Core Features
- **SOS Feed**: A real-time stream of help requests categorized by subjects (Math, Physics, Biology, etc.).
- **Energy Economy**: Create requests by spending energy; earn energy and XP by helping others.
- **Player Progression**: Level up your character and increase your "Utility Score" to gain new ranks (from Newbie to Legend).
- **Guild Chat**: Real-time interaction widget with other members of your guild.
- **Reactive Sidebar**: Live tracking of your level, energy, and contribution stats.

## 🛠 Getting Started

### No Installation Required
This project is a pure frontend application. You don't need `npm install` for basic usage.

### Running Locally
1. Clone the repository.
2. Open `index.html` in your browser.
3. *Recommended*: Use a simple local server to support ES6 Modules:
   ```bash
   # Using Python 3
   python3 -m http.server 8080
   
   # Using Node.js (serve)
   npx serve .
   ```

## 📂 Project Structure
- `index.html`: The shell of the SPA.
- `css/`: Modular stylesheets (variables, layout, components).
- `js/`: Modular logic (store, core engine, functional components).
- `data/`: Configuration and mock data.

## 📈 Roadmap
Check out [todo.md](todo.md) for planned features and improvements.

## 📜 License
MIT License.

---
*Built with neon and code by the Guild-Learn team.*# prizma
