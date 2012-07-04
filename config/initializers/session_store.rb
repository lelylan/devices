# Be sure to restart your server when you modify this file.

<<<<<<< HEAD
Devices::Application.config.session_store :cookie_store, key: '_device_session'
=======
Devices::Application.config.session_store :cookie_store, :key => '_devices_session'
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Devices::Application.config.session_store :active_record_store
