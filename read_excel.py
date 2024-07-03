import pandas as pd

# Replace 'your_file.xlsx' with the actual path to your Excel file
file_path = 'your_file.xlsx'

# Read all sheets into a dictionary
data = pd.read_excel(file_path, sheet_name=None)

# Process each sheet
for sheet_name, sheet_data in data.items():
  # Print sheet name
  print(f"Sheet: {sheet_name}")
  
  # Access and print Key and Text columns
  for index, row in sheet_data[['Key', 'Text']].iterrows():
    key, text = row['Key'], row['Text']
    print(f"\tKey: {key}, Text: {text}")

  # Additional processing (optional)
  # You can perform further operations on each sheet's data here

  print("\n")  # Add a newline between sheets
