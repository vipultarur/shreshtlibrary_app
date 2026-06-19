import os, glob

path = r'd:\extra\shresht\student_app\lib\**\*.dart'

for filepath in glob.glob(path, recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content
        # Replace api_client.dart imports
        new_content = new_content.replace("'../core/api_client.dart'", "'package:student_app/core/network/api_client.dart'")
        new_content = new_content.replace("'../../core/api_client.dart'", "'package:student_app/core/network/api_client.dart'")
        new_content = new_content.replace("import 'api_client.dart';", "import 'package:student_app/core/network/api_client.dart';")

        # Replace api_failure.dart imports
        new_content = new_content.replace("'../core/api_failure.dart'", "'package:student_app/core/errors/api_failure.dart'")
        new_content = new_content.replace("'../../core/api_failure.dart'", "'package:student_app/core/errors/api_failure.dart'")
        new_content = new_content.replace("import 'api_failure.dart';", "import 'package:student_app/core/errors/api_failure.dart';")

        # Replace token_store.dart imports
        new_content = new_content.replace("'../core/token_store.dart'", "'package:student_app/core/network/token_store.dart'")
        new_content = new_content.replace("'../../core/token_store.dart'", "'package:student_app/core/network/token_store.dart'")
        new_content = new_content.replace("import 'token_store.dart';", "import 'package:student_app/core/network/token_store.dart';")

        if content != new_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated {filepath}')
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
