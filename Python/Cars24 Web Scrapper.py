import requests
from bs4 import BeautifulSoup
import openpyxl

excel = openpyxl.Workbook()
sheet = excel.active
sheet.title = 'Cars24'
sheet.append(['Model Name','Price','Details'])



url = "https://www.cars24.com/buy-used-car/?sort=P&storeCityId=5&pinId=122003"

page = requests.get(url)

soup = BeautifulSoup(page.content, 'html.parser')

lists = soup.find_all('div', class_="col-4")


for list in lists:
    model = list.find('h2',class_="_3FpCg")#.text.replace('\n','')
    price = list.find('div',class_="_7udZZ")#.text.replace('\n','')
    details = list.find('ul',class_="bVR0c")#.text.replace('\n','')
   
    info = [model,price,details]
    
    sheet.append([model,price,details])

excel.save('Cars24.xlsx')





    



    




