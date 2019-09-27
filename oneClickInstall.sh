!/bin/bash

mainMenu() {

    clear
    echo "Hi Human, what do you wanna do?"
    echo --------------------------------------------------
    echo "1. Run Apps Locally"
    echo "2. Provision GKE (Google Kubernetes Engine)"
    echo "3. Install Applications on k8s"
    echo "4. Deploy a new Release"
    echo "0. Exit"
    echo
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) appMenu;;
        2) iacMenu;;
        3) k8sMenu;;
        4) deployMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; mainMenu ;;
    esac
}

appMenu() {
    clear
    echo "Which App do want to run locally? Sorted by Priority"
    echo --------------------------------------------------
    echo "1. Static Assets"
    echo "2. Quotes Service"
    echo "3. Newsfeed"
    echo "4. Frontend"
    echo "5. Alles"
    echo "6. Back <-"
    echo "0. Exit"
    echo
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) runDockerFrontendStatic;;
        2) runDockerQuotes;;
        3) runDockerNewsfeed;;
        4) frontendValidation;;
        5) runAll;;
        6) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; appMenu ;;
    esac
}
iacMenu(){
    clear
    echo "Have you replaced the variables on iac/variables.tf? "
    echo --------------------------------------------------
    echo "1. Yes"
    echo "2. No"
    echo "3. Print variables (10 seconds)"
    echo "4. Back <-"
    echo "0. Leave me alone!"
    echo
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) applyTerraform;;
        2) mainMenu;;
        3) printTerraformVariables;;
        4) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; iacMenu ;;
    esac
}

frontendValidation(){
    clear
    echo "Are you confirm that all apps are running? "
    echo --------------------------------------------------
    echo "1. Yes"
    echo "2. No"
    echo "0. Leave me alone!"
    echo
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) runDockerFrontend;;
        2) appMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; echo ; frontendValidation ;;
    esac
}

k8sMenu(){
    clear
    echo "Which app do you wanna do install on k8s? Sorted by Priority "
    echo ------------------------------------------------------------
    echo "1. Static Assets"
    echo "2. Quotes Service"
    echo "3. Newsfeed"
    echo "4. Frontend"
    echo "5. Back <-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read k8sMenuId
    echo
    case $k8sMenuId in
        1) appName="Static Assets"; k8sMenuInstallation;;
        2) appName="Quotes Service"; k8sMenuInstallation;;
        3) appName="Newsfeed"; k8sMenuInstallation;;
        4) appName="Frontend"; k8sMenuInstallation;;
        5) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; k8sMenu ;;
    esac
}

k8sMenuInstallation(){
    clear
    echo " Have you edit ${appName}'s deployment.yaml Manifest?"
    echo ------------------------------------------------------------
    echo "1. Yes"
    echo "2. No, replace for me!"
    echo "3. Back <-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) installk8s;;
        2) replacementK8s;;
        3) k8sMenu;;
        6) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; k8sMenu ;;
    esac

}

replacementK8s(){
    clear
    echo " Please provide your projectId. e.g: fleet-geode-253715"
    echo ------------------------------------------------------------
    echo
    echo -n "Google Project ID==>"
    read googleId
    echo
    if [[ ${k8sMenuId} -eq 4 ]]; then
        clear
        echo " Please provide your Static Assets URL. e.g: 34.102.233.36"
        echo ------------------------------------------------------------
        echo
        echo -n "Static Assets Public IP==>"
        read staticAssetIp
        echo
        # Sed on Mac is weird
        sed  "s/fleet-geode-253715/${googleId}/g"  front-end/k8s/deployments.yaml > front-end/k8s/deployments-tmp.yaml    
        sed  "s/34.102.233.36/${staticAssetIp}/g"  front-end/k8s/deployments-tmp.yaml > front-end/k8s/deployments-tmp2.yaml    
        cp -rp front-end/k8s/deployments-tmp2.yaml  front-end/k8s/deployments.yaml
        rm -rf front-end/k8s/deployments-tmp.yaml
        rm -rf front-end/k8s/deployments-tmp2.yaml        
        installk8s
    elif [ ${k8sMenuId} -eq 1 ]
    then
        sed  "s/fleet-geode-253715/${googleId}/g"  front-end/public/k8s/deployments.yaml > front-end/public/k8s/deployments-tmp.yaml    
        cp -rp front-end/public/k8s/deployments-tmp.yaml  front-end/public/k8s/deployments.yaml
        rm -rf front-end/public/k8s/deployments-tmp.yaml
        installk8s 
    elif [ ${k8sMenuId} -eq 2 ]
    then
        sed  "s/fleet-geode-253715/${googleId}/g"  quotes/k8s/deployments.yaml > quotes/k8s/deployments-tmp.yaml    
        cp -rp quotes/k8s/deployments-tmp.yaml  quotes/k8s/deployments.yaml
        rm -rf quotes/k8s/deployments-tmp.yaml
        installk8s 
    elif [ ${k8sMenuId} -eq 3 ]
    then
        sed  "s/fleet-geode-253715/${googleId}/g"  newsfeed/k8s/deployments.yaml > newsfeed/k8s/deployments-tmp.yaml    
        cp -rp newsfeed/k8s/deployments-tmp.yaml  newsfeed/k8s/deployments.yaml
        rm -rf newsfeed/k8s/deployments-tmp.yaml    
        installk8s 
    fi
}

installk8s(){
    if [[ ${k8sMenuId} -eq 1 ]]; then
        echo "Installing ${appName} ..."
        #kubectl create -f front-end/public/deployments.yaml
        #kubectl create -f front-end/public/services.yaml
        #kubectl create -f front-end/public/ingress.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    elif [ ${k8sMenuId} -eq 2 ]
    then
        echo "Installing ${appName} ..."
        #kubectl create -f quotes/deployments.yaml
        #kubectl create -f quotes/services.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    elif [ ${k8sMenuId} -eq 3 ]
    then
        echo "Installing ${appName} ..."
        #kubectl create -f newsfeed/deployments.yaml
        #kubectl create -f newsfeed/services.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    elif [ ${k8sMenuId} -eq 4 ]
    then
        echo "Installing ${appName} ..."
        #kubectl create -f front-end/secrets.yaml
        #kubectl create -f front-end/deployments.yaml
        #kubectl create -f front-end/services.yaml
        #kubectl create -f front-end/ingress.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    fi
}

printTerraformVariables(){
     echo $(cat iac/variables.tf)
     sleep 10s
     iacMenu
 }

applyTerraform(){
    cd iac/ && terraform plan
    cd ../
    mainMenu
}

runAll(){
    runDockerFrontendStatic
    runDockerQuotes
    runDockerNewsfeed
    runDockerFrontend
}

runDockerFrontendStatic(){
    echo "Building docker image ..."
    docker build --tag frontend-static:1.0  --file front-end/public/Dockerfile .
    echo "Running Docker ..."
    docker run --rm --name frontend-static --publish 8000:8000 frontend-static:1.0
    echo "Done!"
    appMenu
}

runDockerQuotes(){
    echo "Building docker image ..."
    docker build --tag quotes:1.0 --file quotes/Dockerfile .
    echo "Running Docker ..."
    docker run --rm --name quotes --hostname quotes --env APP_PORT=8080 quotes:1.0
    echo "Done!"
    appMenu
}

runDockerNewsfeed(){
    echo "Building docker image ..."
    docker build --tag newsfeed:1.0 --file newsfeed/Dockerfile .
    echo "Running Docker ..."
    docker run --rm --name newsfeed --hostname newsfeed --env APP_PORT=8081 newsfeed:1.0
    echo "Done!"
    appMenu
}

runDockerFrontend(){
    echo "Building docker image ..."
    docker build --tag frontend:1.0 --file front-end/Dockerfile .
    echo "Running Docker ..."
    docker run --rm --name frontend --env APP_PORT=8082 --env STATIC_URL=http://0.0.0.0:8000 --env QUOTE_SERVICE_URL=http://quotes:8080 --env NEWSFEED_SERVICE_URL=http://newsfeed:8081 --env  NEWSFEED_SERVICE_TOKEN="T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX" --link quotes:quotes --link  newsfeed:newsfeed --publish 8082:8082 frontend:1.0
    echo "Done!"
    echo "Please try to access: http://localhost:8082"
    sleep 5s
    mainMenu
}

mainMenu