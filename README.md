# Saleor Frontend Development Environment

This is a streamlined local development environment for Saleor, focusing exclusively on **frontend development**. The backend services (API, Database, etc.) are run from pre-built Docker images, not from local source code.

## 🚀 Quick Start

### 1. Start All Services
This command will start the Saleor backend, database, and other necessary services using the pre-configured Docker images.
```bash
docker-compose up -d
```

### 2. Check Service Status
After starting, run this quick test to ensure all essential services are up and running correctly.
```bash
./quick-test.sh
```

### 3. Access Your Environment
- **Storefront (Your primary focus)**: [http://localhost:3000](http://localhost:3000)
- **Admin Dashboard**: [http://localhost:9001](http://localhost:9001)
- **GraphQL API Playground**: [http://localhost:8000/graphql/](http://localhost:8000/graphql/)

**Default Admin Credentials:**
- **Email**: `admin@example.com`
- **Password**: `admin123`

## 🔧 Frontend Development Workflow

This setup is optimized for frontend development. Here is the typical workflow:

### 1. Making Changes
All your frontend code is located in the `saleor-storefront/` directory. You can freely modify the code there.

### 2. Rebuilding the Frontend Image
After making changes to the storefront code, you need to rebuild the Docker image.
```bash
docker-compose build storefront --no-cache
```

### 3. Restarting the Service
Once the build is complete, restart the storefront container to apply the changes.
```bash
docker-compose restart storefront
```

## 📦 Database Management

Your product data, user accounts, and other information are stored in the database. You can manage it with the backup script.

### Backup the Database
Create a backup of your current database. The file will be saved in the `backups/` directory with a timestamp.
```bash
./backup-database.sh backup
```

### Restore the Database
Restore the database from a backup file.
```bash
./backup-database.sh restore ./backups/YOUR_BACKUP_FILE.sql
```

## 📁 Project Structure

The project has been streamlined to its essential components:

```
vitecover_saleor/
├── saleor-storefront/      # Your frontend source code
├── config/                 # Required backend configuration files
├── backups/                # Directory for database backups
├── docker-compose.yml      # Docker orchestration for all services
├── quick-test.sh           # Script to quickly check service status
├── backup-database.sh      # Script for database backup and restore
└── README.md               # This documentation
```

All backend source code and unnecessary platform files have been removed to simplify the project and save disk space.

## 🐛 Troubleshooting

If you encounter issues, here are some steps to take:

1.  **Run the Quick Test:**
    ```bash
    ./quick-test.sh
    ```
2.  **Check Container Logs:**
    If a service is failing, check its logs. For example, for the storefront:
    ```bash
    docker-compose logs storefront
    ```
3.  **Check Container Status:**
    See which containers are running or have stopped.
    ```bash
    docker-compose ps
    ```
4.  **Restart Services:**
    A simple restart can sometimes resolve issues.
    ```bash
    docker-compose restart
    ```
## Continuous Integration (CI/CD)

This project includes a GitHub Actions workflow to automatically build and publish the storefront Docker image.

### How It Works

1.  **Trigger**: The workflow runs automatically on every `push` to the `main` branch.
2.  **Build**: It builds the `saleor-storefront` Docker image.
3.  **Push**: It pushes the newly built image to Docker Hub, tagged with the latest commit SHA.

The workflow file is located at `.github/workflows/main.yml`.

### Setup Instructions

To enable the CI/CD pipeline, you need to add the following secrets to your GitHub repository settings under **Settings > Secrets and variables > Actions**:

-   `DOCKER_USERNAME`: Your Docker Hub username.
-   `DOCKER_PASSWORD`: Your Docker Hub password or a personal access token.

### Deployment

The workflow includes a placeholder for deployment. To deploy automatically, you will need to replace the placeholder section in `.github/workflows/main.yml` with your server's deployment commands (e.g., using `ssh` to pull the new image and restart your services). 