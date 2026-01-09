# FiveM Economy Dashboard

A comprehensive FiveM dashboard for managing economy, viewing player details, and executing SQL queries (with safety checks). Only ACE permissioned players and admins can access this dashboard.

Note: i will not be proving any update soon..... 

## Features

- **Player Management**: View all online players with their details (ID, name, cash, bank, job)
- **Economy Management**: Add or set player money (cash/bank) in real-time
- **SQL Editor**: Execute SQL queries with built-in safety checks to prevent destructive operations
- **ACE Permission System**: Only players with the configured ACE permission can access the dashboard
- **Modern UI**: Beautiful, responsive dashboard with smooth animations

## Installation

1. Place the `m_dashboard` folder in your FiveM server's `resources` directory
2. Add `ensure m_dashboard` to your `server.cfg`
3. Configure the resource in `config.lua`:
   - Set your ACE permission (default: "admin")
   - Configure your framework (ESX, QB-Core, or standalone)
   - Configure your database (oxmysql, mysql-async, or ghmattimysql)

## Configuration

Edit `config.lua` to match your server setup:

```lua
Config.AdminPermission = "admin"  -- Your ACE permission
Config.Framework = "esx"          -- "esx", "qb-core", or "standalone"
Config.Database = "oxmysql"       -- "oxmysql", "mysql-async", or "ghmattimysql"
```

## ACE Permissions

To grant access to the dashboard, add this to your server.cfg:

```
add_ace group.admin rm_dashboard allow
```

Or for specific players:

```
add_ace identifier.steam:YOUR_STEAM_ID rm_dashboard allow
```

## Usage

Players with the required ACE permission can open the dashboard using:

```
/dashboard
```

## Features Breakdown

### Players Tab
- View all online players
- See player ID, name, cash, bank, and job information
- Click on a player card to view detailed information
- Auto-refreshes every 5 seconds

### Economy Tab
- Select a player from the dropdown
- View current cash and bank balance
- Add money to player's cash or bank
- Set player's cash or bank to a specific amount

### SQL Editor Tab
- Execute SQL queries safely
- Built-in protection against destructive operations (DROP, DELETE, TRUNCATE, etc.)
- View query results in formatted JSON
- Maximum query length protection

## Safety Features

The SQL editor includes multiple safety checks:
- Blocks dangerous keywords (DROP, DELETE, TRUNCATE, etc.)
- Maximum query length limit
- Can be completely disabled via config
- Only accessible to ACE permissioned users

## Framework Support

Currently supports:
- **ESX**: Full support for ESX framework
- **QB-Core**: Full support for QB-Core framework
- **Standalone**: Basic support (may require customization)

## Database Support

Supports:
- **oxmysql**: Recommended
- **mysql-async**: Legacy support
- **ghmattimysql**: Legacy support

## Troubleshooting

1. **Dashboard doesn't open**: Check if you have the correct ACE permission
2. **Players not loading**: Verify your framework is correctly configured
3. **SQL queries failing**: Check your database configuration and ensure the query doesn't contain blocked keywords
4. **Money not updating**: Verify your framework is correctly set up and the player is online

## License

This resource is provided as-is. Modify as needed for your server.

