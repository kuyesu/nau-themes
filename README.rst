NAU Themes for OpenEdx
======================
This repository contains the NAU themes.

How to update translations
==========================

.. code-block:: bash

   virtualenv venv-theme
   source venv-theme/bin/activate
   pip install -r requirements.txt
   make update_translations # this will extract the chains and add them to the .po files
   # add/update the translations in the .po files, (text editor, POEdit, ...)
   make compile_translations # this will generate the .mo files


Extra information. Added the following modules to the environment in order
to get translations from .underscore files:

.. code-block:: bash

   pip install django-babel-underscore
   pip install mako
