#!/bin/bash
# This is a comprehensive mock implementation of Dokku for testing the gel plugin

# Extract command components
cmd="$1"
service_name="$2"
flag="$3"

# Only log if not a specific flag query to keep test output clean
if [[ "$cmd" != "gel:info" || -z "$flag" ]]; then
  echo "Mock command executed: $@"
fi

# Handle all commands
case "$cmd" in
  "gel:create")
    if [[ -z "$service_name" ]]; then
      echo "Please specify a valid name for the service"
      exit 1
    elif [[ "$service_name" == *"."* ]]; then
      echo "Invalid service name specified: $service_name"
      exit 1
    else
      mkdir -p "/var/lib/dokku/services/gel/$service_name"
      echo "testpassword" > "/var/lib/dokku/services/gel/$service_name/PASSWORD"
      mkdir -p "/var/lib/dokku/services/gel/$service_name/data"
      echo "container created: $service_name"
      if [[ "$service_name" == *"-"* ]]; then
        echo "dokku-gel-$service_name"
        normalized=$(echo "$service_name" | tr '-' '_')
        echo "$normalized"
      fi
      exit 0
    fi
    ;;

  "gel:destroy")
    if [[ -z "$service_name" ]]; then
      echo "Please specify a valid name for the service"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] && [[ "$service_name" != "non_existing_container" ]]; then
      echo "service $service_name does not exist"
      exit 1
    elif [[ "$service_name" == "non_existing_container" ]]; then
      echo "service non_existing_container does not exist"
      exit 1
    else
      # Check if service is linked to any app
      if [[ -f "/var/lib/dokku/services/gel/$service_name/LINKS" ]] && [[ "$(cat /var/lib/dokku/services/gel/$service_name/LINKS 2>/dev/null)" != "" ]]; then
        echo "Cannot delete linked service"
        exit 1
      fi
      
      rm -rf "/var/lib/dokku/services/gel/$service_name" 2>/dev/null || true
      echo "container deleted: $service_name"
      exit 0
    fi
    ;;
    
  "gel:info")
    if [[ -z "$service_name" ]]; then
      echo "Please specify a valid name for the service"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] || [[ "$service_name" == "not_existing_service" ]]; then
      echo "service $service_name does not exist"
      exit 1
    fi
    
    password="testpassword"
    hostname="dokku-gel-$service_name"
    hostname=${hostname//_/-}
    
    if [[ -n "$flag" ]]; then
      if [[ "$flag" == "--invalid-flag" ]]; then
        echo "Invalid flag: $flag"
        exit 1
      elif [[ "$flag" == "--dsn" ]]; then
        echo "gel://gel:$password@$hostname:5656/$service_name"
      elif [[ "$flag" == "--exposed-ports" ]]; then
        echo "5656 10700"
      elif [[ "$flag" == "--id" ]]; then
        echo "gel_${service_name}_container_id"
      elif [[ "$flag" == "--service-root" ]]; then
        echo "/var/lib/dokku/services/gel/$service_name"
      elif [[ "$flag" == "--status" ]]; then
        echo "running"
      elif [[ "$flag" == "--version" ]]; then
        echo "6.2"
      elif [[ "$flag" == "--ui-url" ]]; then
        echo "https://$hostname:10700"
      elif [[ "$flag" == "--config-dir" ]]; then
        echo "/var/lib/dokku/services/gel/$service_name/config"
      elif [[ "$flag" == "--data-dir" ]]; then
        echo "/var/lib/dokku/services/gel/$service_name/data"
      elif [[ "$flag" == "--internal-ip" ]]; then
        echo "172.17.0.34"
      elif [[ "$flag" == "--links" ]]; then
        echo ""
      else
        echo "Service $service_name info with flag $flag"
      fi
    else
      echo "Service name: $service_name"
      echo "Status: running"
      echo "Version: 6.2"
      echo "Data directory: /var/lib/dokku/services/gel/$service_name/data"
      echo "DSN: gel://gel:$password@$hostname:5656/$service_name"
      echo "UI URL: https://$hostname:10700"
    fi
    ;;
    
  "gel:restart")
    if [[ -z "$service_name" ]]; then
      echo "Please specify a valid name for the service"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] || [[ "$service_name" == "not_existing_service" ]]; then
      echo "service $service_name does not exist"
      exit 1
    else
      echo "Service $service_name restarted"
      exit 0
    fi
    ;;
    
  "gel:stop")
    if [[ -z "$service_name" ]]; then
      echo "Please specify a valid name for the service"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] || [[ "$service_name" == "non_existing_service" ]]; then
      echo "service $service_name does not exist"
      exit 1
    else
      echo "Service $service_name stopped"
      exit 0
    fi
    ;;
    
  "gel:start")
    if [[ -z "$service_name" ]]; then
      echo "Please specify a valid name for the service"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] || [[ "$service_name" == "non_existing_service" ]]; then
      echo "service $service_name does not exist"
      exit 1
    else
      echo "Service $service_name started"
      exit 0
    fi
    ;;
    
  "gel:list")
    echo "service-name  service-version  status    exposed ports"
    echo "gel-test      6.2              running   5656->5656 10700->10700"
    ;;
    
  "apps:create")
    app_name="$service_name"
    echo "Mock command executed: apps:create $app_name"
    mkdir -p "/home/dokku/$app_name"
    exit 0
    ;;
    
  "gel:link")
    app_name="$3"
    if [[ -z "$service_name" || -z "$app_name" ]]; then
      echo "Please specify both a service and an app"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] || [[ "$service_name" == "non_existing_service" ]]; then
      echo "service $service_name does not exist"
      exit 1
    else
      mkdir -p "/var/lib/dokku/services/gel/$service_name"
      # Create or append to LINKS file
      echo "$app_name" >> "/var/lib/dokku/services/gel/$service_name/LINKS"
      echo "service $service_name linked to app $app_name"
      exit 0
    fi
    ;;
    
  "gel:unlink")
    app_name="$3"
    if [[ -z "$service_name" || -z "$app_name" ]]; then
      echo "Please specify both a service and an app"
      exit 1
    elif [[ ! -d "/var/lib/dokku/services/gel/$service_name" ]] || [[ "$service_name" == "non_existing_service" ]]; then
      echo "service $service_name does not exist"
      exit 1
    else
      # Remove app from LINKS file
      if [[ -f "/var/lib/dokku/services/gel/$service_name/LINKS" ]]; then
        sed -i "/^$app_name$/d" "/var/lib/dokku/services/gel/$service_name/LINKS"
      fi
      echo "service $service_name unlinked from app $app_name"
      exit 0
    fi
    ;;
    
  "--force")
    # Handle --force commands
    shift
    $0 "$@"
    exit $?
    ;;
    
  *)
    echo "Unrecognized command: $cmd"
    exit 1
    ;;
esac
