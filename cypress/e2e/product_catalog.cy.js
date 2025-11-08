describe('E-commerce Product Catalog', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('should display products on the page', () => {
    cy.get('.product').should('have.length', 4);
    cy.get('.product h3').should('contain', 'Wireless Headphones');
    cy.get('.product h3').should('contain', 'Smart Watch');
    cy.get('.product h3').should('contain', 'Bluetooth Speaker');
    cy.get('.product h3').should('contain', 'Phone Charger');
  });

  it('should add items to cart and update counter', () => {
    cy.get('#cart-count').should('have.text', '0');

    cy.get('[data-name="Wireless Headphones"]').click();
    cy.get('#cart-count').should('have.text', '1');

    cy.get('[data-name="Smart Watch"]').click();
    cy.get('#cart-count').should('have.text', '2');

    cy.get('[data-name="Wireless Headphones"]').click();
    cy.get('#cart-count').should('have.text', '3'); // Adding same item increases quantity
  });

  it('should show cart when cart button is clicked', () => {
    cy.get('#cart-modal').should('not.be.visible');

    cy.get('#cart-toggle').click();
    cy.get('#cart-modal').should('be.visible');
  });

  it('should add item to cart and show in cart view', () => {
    cy.get('#cart-modal').should('not.be.visible');

    // Add an item to the cart
    cy.get('[data-name="Wireless Headphones"]').click();
    
    // Open the cart to see the added item
    cy.get('#cart-toggle').click();
    
    cy.get('#cart-items').should('contain', 'Wireless Headphones');
    cy.get('#total-price').should('contain', '99.99');
  });

  it('should update cart total when items are added', () => {
    cy.get('[data-name="Wireless Headphones"]').click();
    cy.get('[data-name="Bluetooth Speaker"]').click();

    cy.get('#cart-toggle').click();
    cy.get('#total-price').should('contain', '179.98'); // 99.99 + 79.99
  });
  
  it('should handle form validation', () => {
    cy.get('#cart-toggle').click();
    
    cy.get('#purchase-form').within(() => {
      cy.get('button[type="submit"]').click();
    });
    
    // We expect an alert or form error - checking for required field validation
    cy.on('window:alert', (str) => {
      expect(str).to.contain('Please fill in all required fields');
    });
  });

  it('should complete purchase flow', () => {
    cy.get('[data-name="Wireless Headphones"]').click();
    cy.get('[data-name="Smart Watch"]').click();
    
    cy.get('#cart-toggle').click();
    
    cy.get('#purchase-form').within(() => {
      cy.get('#name').type('John Doe');
      cy.get('#email').type('john@example.com');
      cy.get('button[type="submit"]').click();
    });
    
    cy.get('#success-message').should('be.visible');
    cy.get('#checkout-form').should('have.class', 'hidden');
    
    // Cart should be cleared
    cy.get('#cart-count').should('have.text', '0');
  });
});