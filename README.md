<<<<<<< HEAD
<h3 align="center">✨ Tech Stack ✨</h3>
<div align="center">
  <img src="https://img.shields.io/badge/IT-20232a.svg?style=for-the-badge&logo=react&logoColor=orange" />&nbsp
  <img src="https://img.shields.io/badge/Java-F7DF1E.svg?style=for-the-badge&logo=java&logoColor=20232a" />&nbsp
  <img src="https://img.shields.io/badge/Python-E34F26.svg?style=for-the-badge&logo=#python&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/MySQL-27588a.svg?style=for-the-badge&logo=#python&logoColor=white" />&nbsp

  [![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&center=true&width=435&lines=An+engineering+student)](https://git.io/typing-svg)

  
</div>
=======
# Simple E-Commerce Product Catalog

A simple e-commerce product catalog with product display, cart functionality, and checkout form. Built with vanilla HTML, CSS, and JavaScript, with Cypress end-to-end testing.

## Features

- Display 4 products in a responsive grid layout
- Add/remove items from cart
- Real-time cart counter and total price calculation
- Toggle cart view modal
- Checkout form with validation
- Success message after purchase

## Project Structure

```
simple-ecommerce-catalog/
├── index.html
├── style.css
├── script.js
├── package.json
├── cypress/
│   └── e2e/
│       └── product_catalog.cy.js
├── cypress.config.js
└── README.md
```

## Setup Instructions

1. Clone or download this repository

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Open your browser to `http://localhost:55000`

## Running Tests

To run Cypress tests in interactive mode:
```bash
npm test
```

To run Cypress tests in headless mode:
```bash
npm run cypress:run
```

## Technologies Used

- HTML5
- CSS3 (with Grid and Flexbox)
- Vanilla JavaScript
- Cypress (for end-to-end testing)

## Code Features

- Responsive design that works on mobile, tablet, and desktop
- Clean, modular JavaScript with no external frameworks
- Cart functionality using array manipulation
- Form validation and user feedback
- Accessible UI components

## File Descriptions

- `index.html` - Main page with product grid and cart modal
- `style.css` - Responsive styling with grid layout
- `script.js` - Cart logic and form handling
- `cypress/e2e/product_catalog.cy.js` - End-to-end tests
>>>>>>> 3b502f8 (Initial commit)
