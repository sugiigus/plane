# Generated for the Japanese self-hosted Plane deployment.

import pytz
from django.db import migrations, models


TIMEZONE_CHOICES = tuple(zip(pytz.common_timezones, pytz.common_timezones))


def migrate_utc_defaults_to_tokyo(apps, schema_editor):
    Workspace = apps.get_model("db", "Workspace")
    User = apps.get_model("db", "User")

    # This instance was initialized for Japan; the only existing UTC values are
    # defaults created during first-run setup, not user-selected preferences.
    Workspace.objects.filter(timezone="UTC", deleted_at__isnull=True).update(timezone="Asia/Tokyo")
    User.objects.filter(user_timezone="UTC").update(user_timezone="Asia/Tokyo")


class Migration(migrations.Migration):
    dependencies = [
        ("db", "0122_profile_default_language_ja"),
    ]

    operations = [
        migrations.RunPython(migrate_utc_defaults_to_tokyo, migrations.RunPython.noop),
        migrations.AlterField(
            model_name="workspace",
            name="timezone",
            field=models.CharField(
                choices=TIMEZONE_CHOICES,
                default="Asia/Tokyo",
                max_length=255,
            ),
        ),
        migrations.AlterField(
            model_name="user",
            name="user_timezone",
            field=models.CharField(
                choices=TIMEZONE_CHOICES,
                default="Asia/Tokyo",
                max_length=255,
            ),
        ),
    ]
