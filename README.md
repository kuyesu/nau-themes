# NAU Themes for OpenEdx

This repository contains the NAU themes.

## How to update translations

```bash
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
make update_translations # this will extract the chains and add them to the .po files
# add/update the translations in the .po files, (text editor, POEdit, ...)
make compile_translations # this will generate the .mo files
```

### Devstack

To update translations on devstack it's require to run:

For LMS:
```bash
make publish_lms_devstack
```

For STUDIO:
```bash
make publish_studio_devstack
```
