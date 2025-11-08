// Cart array to store added items
let cart = [];

// DOM elements
const cartToggle = document.getElementById('cart-toggle');
const cartCount = document.getElementById('cart-count');
const cartModal = document.getElementById('cart-modal');
const cartItems = document.getElementById('cart-items');
const totalPrice = document.getElementById('total-price');
const closeBtn = document.querySelector('.close');
const purchaseForm = document.getElementById('purchase-form');
const checkoutForm = document.getElementById('checkout-form');
const successMessage = document.getElementById('success-message');
const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');

// Event listeners
cartToggle.addEventListener('click', toggleCart);
closeBtn.addEventListener('click', closeCart);
window.addEventListener('click', (e) => {
  if (e.target === cartModal) {
    closeCart();
  }
});

// Add to cart event listeners
addToCartButtons.forEach(button => {
  button.addEventListener('click', (e) => {
    const product = e.target.closest('.product');
    const id = e.target.dataset.id;
    const name = e.target.dataset.name;
    const price = parseFloat(e.target.dataset.price);
    
    addToCart(id, name, price);
  });
});

// Form submission
purchaseForm.addEventListener('submit', handleFormSubmit);

// Functions
function toggleCart() {
  cartModal.style.display = cartModal.style.display === 'block' ? 'none' : 'block';
  updateCartView();
}

function closeCart() {
  cartModal.style.display = 'none';
}

function addToCart(id, name, price) {
  // Check if item already exists in cart
  const existingItem = cart.find(item => item.id === id);
  
  if (existingItem) {
    existingItem.quantity++;
  } else {
    cart.push({
      id,
      name,
      price,
      quantity: 1
    });
  }
  
  updateCartCount();
  updateCartView();
}

function removeFromCart(id) {
  cart = cart.filter(item => item.id !== id);
  updateCartCount();
  updateCartView();
}

function updateCartCount() {
  const count = cart.reduce((total, item) => total + item.quantity, 0);
  cartCount.textContent = count;
}

function updateCartView() {
  // Clear current cart display
  cartItems.innerHTML = '';
  
  if (cart.length === 0) {
    cartItems.innerHTML = '<li class="cart-item">Your cart is empty</li>';
    totalPrice.textContent = '0.00';
    return;
  }
  
  // Add each item to the cart display
  let total = 0;
  cart.forEach(item => {
    const itemTotal = item.price * item.quantity;
    total += itemTotal;
    
    const li = document.createElement('li');
    li.className = 'cart-item';
    li.innerHTML = `
      <div>
        <span>${item.name} (${item.quantity})</span>
        <button class="remove-item" data-id="${item.id}">Remove</button>
      </div>
      <div>$${itemTotal.toFixed(2)}</div>
    `;
    
    cartItems.appendChild(li);
  });
  
  totalPrice.textContent = total.toFixed(2);
  
  // Add event listeners to remove buttons
  document.querySelectorAll('.remove-item').forEach(button => {
    button.addEventListener('click', (e) => {
      const id = e.target.getAttribute('data-id');
      removeFromCart(id);
    });
  });
}

function handleFormSubmit(e) {
  e.preventDefault();
  
  // Get form values
  const name = document.getElementById('name').value.trim();
  const email = document.getElementById('email').value.trim();
  
  // Basic form validation
  if (!name || !email) {
    alert('Please fill in all required fields');
    return;
  }
  
  // Show success message
  checkoutForm.classList.add('hidden');
  successMessage.classList.remove('hidden');
  
  // Clear cart after successful purchase
  setTimeout(() => {
    cart = [];
    updateCartCount();
    updateCartView();
  }, 1000);
  
  // Reset form after a delay
  setTimeout(() => {
    purchaseForm.reset();
  }, 3000);
}