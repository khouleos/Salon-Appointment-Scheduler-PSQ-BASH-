#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# display services
echo -e "\n~~~~~Welcome to Salon Shop ~~~~~\n"

SERVICES_FUN() {
if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
LIST_OF_SERVICES=$($PSQL "select * from services")
echo "$LIST_OF_SERVICES" | while read SERVICE_ID NAME 
do
echo "$SERVICE_ID)$(echo $NAME | sed 's/|//')"
done

}


# ask for service
SERVICES_FUN "Welcome to My Salon, how can I help you?"
read SERVICE_ID_SELECTED
# if it's not a number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
  # send to service list
SERVICES_FUN "I could not find that service. What would you like today?"
  else

  # check if service is available
SERVICE_AVAILABILITY=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
    # send to service list
    SERVICES_FUN "please entre the right number of service"
    else
    # get customer number
    echo -e "\nEntre your phone number :"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_NAME ]]
        then
        # ask for customer info
        echo -e "\nWe don't have a record for that phone number, what's your name ?"
        read CUSTOMER_NAME
        # insert customer info
        INSERT_NAME=$($PSQL "insert into customers (name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
        # get customer name
        SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")
        fi
        GET_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *//g'), $CUSTOMER_NAME ?"
        read SERVICE_TIME
        # insert appointment
        INSERT_TIME=$($PSQL "insert into appointments(time, customer_id, service_id) values('$SERVICE_TIME', '$GET_CUSTOMER_ID', '$SERVICE_ID_SELECTED')")
          if [[ $INSERT_TIME = 'INSERT 0 1' ]]
          then
          echo "I have put you down for a $(echo $SERVICE_NAME | sed -r s'/^ *//g') at $SERVICE_TIME, $CUSTOMER_NAME."          
        fi
      fi
fi