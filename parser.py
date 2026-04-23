import requests
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

driver = webdriver.Chrome(options=options)
driver.get('https://kazhydromet.kz/ru')

wait = WebDriverWait(driver, 10)

# Кликаем на dropdown
dropdown = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '.middle-header__city')))
dropdown.click()
time.sleep(3)

# Выбираем Астану
astana = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'Астана')]")))
astana.click()

# Ждём загрузки погоды
wait.until(EC.presence_of_element_located((By.ID, 'weather_day')))

day = driver.find_element(By.ID, 'weather_day')
temp = day.find_element(By.TAG_NAME, 'h2').text

driver.quit()

requests.post("http://localhost:5001/webhook", json={"weather": temp})

