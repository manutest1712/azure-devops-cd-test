#!/usr/bin/env python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time

from selenium.webdriver.support.wait import WebDriverWait


# Start the browser and login with standard_user
def login(user, password):
    print("\n=== Starting UI Test Suite (Linux) ===")
    print("Launching Chrome browser...")

    chrome_options = ChromeOptions()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--headless=new")
    driver = webdriver.Chrome(options=chrome_options)

    # Uncomment if running on a headless Linux server (CI/CD pipelines)
    # chrome_options.add_argument("--headless=new")
    print("Browser launched successfully.")

    driver.get("https://www.saucedemo.com/")
    print("Navigated to saucedemo login page.")

    print(f"Attempting login for user: {user}")

    driver.find_element(By.ID, "user-name").send_keys(user)
    driver.find_element(By.ID, "password").send_keys(password)
    driver.find_element(By.ID, "login-button").click()

    print("Login button clicked... Checking login status...")

    time.sleep(10)
    if "inventory" in driver.current_url:
        print("Login successful ✔")
    else:
        print("Login failed ❌")
        driver.quit()
        return None

    return driver


def add_all_products(driver):
    print("Adding all products to the cart...")

    # Step 1: Locate ALL add-to-cart buttons
    add_buttons = driver.find_elements(By.CSS_SELECTOR, "button[id^='add-to-cart']")
    count_products = len(add_buttons)

    print(f"Total items found: {count_products}")

    # Step 2: Assert 6 products exist
    assert count_products == 6, f"Expected 6 products, but found {count_products}"

    # Step 3: Add each product
    for btn in add_buttons:
        product_name = btn.get_attribute("id").replace("add-to-cart-", "")
        print(f"Adding item: {product_name}")
        driver.execute_script("arguments[0].click();", btn)

        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, f"remove-{product_name}"))
        )

    print("All items successfully added to the cart.")

    # Step 4: Locate cart icon (not clicked yet)
    cart_icon = driver.find_element(By.CSS_SELECTOR, ".shopping_cart_link")
    print("Cart icon located.")

    # Step 5: Validate cart badge (item count)
    try:
        cart_badge = WebDriverWait(driver, 5).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, ".shopping_cart_badge"))
        )
        cart_count = cart_badge.text
        print("Items in Cart:", cart_count)

        # Assert that cart has 6 items (since all added)
        assert cart_count == "6", f"Cart count mismatch! Expected 6 but found {cart_count}"

    except Exception as e:
        print("⚠️ No items added to cart! Badge not found.")
        print("Error:", str(e))
        assert False, f"Test failed: Cart badge should exist. Error: {e}"


def remove_all_products(driver):
    print("Removing all products from the cart...")

    # Step 1: Locate ALL remove buttons (they appear only after adding products)
    remove_buttons = driver.find_elements(By.CSS_SELECTOR, "button[id^='remove']")
    count_remove = len(remove_buttons)

    print(f"Total removable items found: {count_remove}")

    # Assert there are 6 items to remove
    assert count_remove == 6, f"Expected 6 remove buttons, but found {count_remove}"

    # Step 2: Click each "Remove" button
    for btn in remove_buttons:
        product_name = btn.get_attribute("id").replace("remove-", "")
        print(f"Removing item: {product_name}")
        driver.execute_script("arguments[0].click();", btn)

        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.ID, f"add-to-cart-{product_name}"))
        )

    print("All items successfully removed from the cart.")

    # Step 3: Validate cart badge again
    try:
        # Wait for badge to disappear (cart empty)
        WebDriverWait(driver, 5).until(
            EC.invisibility_of_element_located((By.CSS_SELECTOR, ".shopping_cart_badge"))
        )
        print("Cart is empty — badge not visible (expected behavior).")

    except:
        # Badge still exists → check its count
        cart_badge = driver.find_element(By.CSS_SELECTOR, ".shopping_cart_badge")
        cart_count = cart_badge.text
        print("Items still in cart after removal:", cart_count)

        assert cart_count == "0", f"Cart should be empty but found {cart_count}"


def run_test():
    driver = login("standard_user", "secret_sauce")
    if driver is None:
        return

    add_all_products(driver)
    remove_all_products(driver)

    print("\n=== Test Completed. Closing browser. ===")
    time.sleep(1)
    driver.quit()


run_test()
