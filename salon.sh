#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\nSalon Appointment Scheduler\n"
#function that shows the services offered
SERVICES_OFFERED() {
  #if the function has an argument(first argument)
    if [[ $1 ]]
      then
      #print the first argument
      echo "$1"
    fi
    echo -e "\nWelcome to our Salon\n"
    echo -e "\nHere are our services"
    #accessing services from the services table using pipe and while loop
      $PSQL "SELECT service_id, name FROM services" |
      while read SERVICE_ID BAR NAME
      do
        # if $SERVICE_ID is a number the print the $SERVICE_ID and name
        if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
          then
          # Use sed to remove the leading space from the name
          echo "$SERVICE_ID) $(echo "$NAME" | sed -E 's/^ +| +$//g')"
          fi
      done
      echo "4) Exit."
      #input the service from the ones provided
    read SERVICE_ID_SELECTED
    #case case for handling menu
    case $SERVICE_ID_SELECTED in
    1) CUT_SERVICE
    ;;
    2) BRAIDING_SERVICE
    ;;
    3) FRONTAL_SERVICE
    ;;
    4) EXIT
    ;;
    *) SERVICES_OFFERED "We do not offer such service"
    ;;
    esac
} 
#function for appointment scheduling
CUSTOMER_APPOINTMENT(){
  echo -e "\nPlease type your phone number\n";
  #input for customer number 
   read CUSTOMER_PHONE
   #check if customer is on our DB
   CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
   #if customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
      then
      #get new customer name
      echo -e "\nPlease provide your name\n";
      read CUSTOMER_NAME
      #INPUT INTO customers table
      INSERT_TO_CUSTOMERS_TABLE=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      
      fi

      # --- Appointment Logic (Shared by both New and Old customers) ---
      #get service name
     SERVICE_REQUESTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
     #if service does not exist
     if [[ -z $SERVICE_REQUESTED ]]
      then
        SERVICES_OFFERED "We dont offer such service"
      fi
      #format service name and customer name
     SERVICE_NAME_FORMATTED=$(echo $SERVICE_REQUESTED | sed 's/ //g')
     CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')
     
      echo "What time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      #input service time
     read SERVICE_TIME
      
     #get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    #schedule appointment
      SCHEDULE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")

      if [[ $SCHEDULE_APPOINTMENT == "INSERT 0 1" ]]
      then
        echo "I have put you down for a $SERVICE_REQUESTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
}
#service function called when a menu is selected thereby calling the customer appointment function to schedule an appointment
CUT_SERVICE() {
  CUSTOMER_APPOINTMENT
}
BRAIDING_SERVICE() {
   CUSTOMER_APPOINTMENT
}
FRONTAL_SERVICE() {
  CUSTOMER_APPOINTMENT
}
WIG_REPAIR_SERVICE() {
  CUSTOMER_APPOINTMENT
}
EXIT() {
  echo -e "\nThank you for stopping in. Hope to see you soon\n"
}
SERVICES_OFFERED