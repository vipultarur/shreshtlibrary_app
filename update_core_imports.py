import os, glob

path = r'd:\extra\shresht\student_app\lib\**\*.dart'

for filepath in glob.glob(path, recursive=True):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content
        
        # Replace absolute package imports
        new_content = new_content.replace("'package:student_app/src/config/", "'package:student_app/core/config/")
        new_content = new_content.replace("'package:student_app/src/models/", "'package:student_app/core/models/")
        new_content = new_content.replace("'package:student_app/src/routing/", "'package:student_app/core/routing/")
        new_content = new_content.replace("'package:student_app/src/services/", "'package:student_app/core/services/")
        new_content = new_content.replace("'package:student_app/src/shared/", "'package:student_app/common/widgets/")
        
        # Replace common relative imports
        # For simplicity, just replacing 'src/' when we know what follows
        new_content = new_content.replace("'../src/config/", "'../core/config/")
        new_content = new_content.replace("'../../src/config/", "'../../core/config/")
        new_content = new_content.replace("'../src/models/", "'../core/models/")
        new_content = new_content.replace("'../../src/models/", "'../../core/models/")
        new_content = new_content.replace("'../src/routing/", "'../core/routing/")
        new_content = new_content.replace("'../../src/routing/", "'../../core/routing/")
        new_content = new_content.replace("'../src/services/", "'../core/services/")
        new_content = new_content.replace("'../../src/services/", "'../../core/services/")
        new_content = new_content.replace("'../src/shared/", "'../common/widgets/")
        new_content = new_content.replace("'../../src/shared/", "'../../common/widgets/")
        
        # In features, they often import `../../shared/` instead of `../../src/shared/` because they were both in src
        # Before: import '../../shared/widgets.dart';
        # After: import '../../common/widgets/widgets.dart'; (or package import)
        new_content = new_content.replace("'../../shared/", "'package:student_app/common/widgets/")
        new_content = new_content.replace("'../shared/", "'package:student_app/common/widgets/")
        
        new_content = new_content.replace("'../../models/", "'package:student_app/core/models/")
        new_content = new_content.replace("'../models/", "'package:student_app/core/models/")
        
        new_content = new_content.replace("'../../services/", "'package:student_app/core/services/")
        new_content = new_content.replace("'../services/", "'package:student_app/core/services/")
        
        new_content = new_content.replace("'../../config/", "'package:student_app/core/config/")
        new_content = new_content.replace("'../config/", "'package:student_app/core/config/")

        if content != new_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated {filepath}')
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
