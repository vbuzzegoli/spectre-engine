# Public Folder

User preferences will be saved here by the CLI, and will further be used in the build phase in order to generate the application.

## Preferences

If custom preferences are provided by a different party than the CLI, they must be saved as `preferences.json` in this folder.

### Available settings

```json
{
  "url": "https://example.com",
  "ghostMode": true,
  "width": 1200,
  "height": 1000,
  "fullscreen": false,
  "title": "App Name",
  "imagePath": "/Documents/image.png",
  "imageUrl": "https://example.com/image.png",
  "useApplicationFolder": true
}
```

> Note: `title` and `url` are required. Other parameters are optional.
