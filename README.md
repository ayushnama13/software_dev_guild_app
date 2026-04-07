# NovaNews 📰✨

NovaNews is a modern, full-stack cross-platform news application that provides users with real-time global headlines, intelligent AI-powered article summaries, and a cloud-synced library for bookmarking favorite reads.

Designed with a sleek user interface, NovaNews integrates NewsAPI for live updates and Google's Gemini AI to deliver concise, 2-sentence overviews of any article.

## 🌟 Features

* **Real-Time Global News:** Browse top headlines across multiple categories (General, Technology, Business, Science, Health, Entertainment) using NewsAPI.
* **AI-Powered Summaries:** Instantly generate concise, 2-sentence article overviews powered by Google's Gemini-3-Flash AI.
* **Cloud-Synced Library:** Bookmark articles to read later. Bookmarks are securely saved to a cloud database and accessible across devices.
* **User Authentication:** Secure email/password login and signup flow with password hashing (SHA-256).
* **Advanced Search:** Search for specific news topics globally.
* **Customizable UI:** Beautiful interface with smooth animations (flip transitions, typing effects) and a Dark/Light mode toggle that saves your preference.

## 🛠️ Tech Stack

### Frontend (Mobile App)

* **Framework:** Flutter & Dart  
* **AI Integration:** Google Generative AI (`gemini-3-flash-preview`)  
* **State Management & Storage:** `ValueNotifier`, `shared_preferences`  
* **Networking:** `http` package for REST API communication  
* **Environment Management:** `flutter_dotenv`  

### Backend (REST API)

* **Framework:** Python, FastAPI, Uvicorn  
* **Database:** Supabase (PostgreSQL) integrated via `psycopg2`  
* **Authentication:** Custom JWT/Session logic with SHA-256 hashing  

---

## 📂 Project Structure

The project is divided into two main directories:

* `novanews/` - The Flutter frontend application.  
* `Novanews_backend/` - The FastAPI backend service.  

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (v3.10.0 or higher)  
* Python (v3.8 or higher)  
* API Keys for NewsAPI, Google Gemini, and Supabase  

---

### 1. Backend Setup (FastAPI)

```bash
cd Novanews_backend
```

```bash
python -m venv venv
source venv/bin/activate
```

```bash
pip install -r requirements.txt
```

```env
SupaBase_Password=your_supabase_password_here
```

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

### 2. Frontend Setup (Flutter)

```bash
cd novanews
```

```bash
flutter pub get
```

```env
NEWS_API_KEY=your_newsapi_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

```bash
flutter run
```

---

## 📝 Important Notes for Deployment

**API Endpoints:**  
Update backend IP if running locally.

**Security:**  
Never commit `.env` files.

---

## 👨‍💻 Author
Ayush Nama
