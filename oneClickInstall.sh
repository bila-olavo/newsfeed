!/bin/bash

mainMenu() {

    clear
    echo "Hi Human, what do you wanna do?"
    echo --------------------------------------------------
    echo "1. Run apps locally"
    echo "2. Provision k8s cluster (Google Kubernetes Engine - GKE)"
    echo "3. Install apps on k8s"
    echo "4. Deploy a new release"
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
    echo "5. Back <-"
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
        5) mainMenu;;
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
    echo "Which app do you wanna install on k8s? Sorted by Priority "
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
        1) appName="frontend-static"; k8sMenuInstallation;;
        2) appName="quotes"; k8sMenuInstallation;;
        3) appName="newsfeed"; k8sMenuInstallation;;
        4) appName="frontend"; k8sMenuInstallation;;
        5) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; k8sMenu ;;
    esac
}

deployMenu(){
    clear
    echo "Which app do wanna deploy a new release?"
    echo ------------------------------------------------------------
    echo "1. Static Assets"
    echo "2. Quotes Service"
    echo "3. Newsfeed"
    echo "4. Frontend"
    echo "5. Back <-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read deployMenuId
    echo
    case $deployMenuId in
        1) appName="frontend-static"; dockerTagMenu;;
        2) appName="quotes"; dockerTagMenu;;
        3) appName="newsfeed"; dockerTagMenu;;
        4) appName="frontend"; dockerTagMenu;;
        5) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; deployMenu ;;
    esac
}

rolloutImage(){
    kubectl set image deployment/${appName}-deployment ${appName}-deployment=gcr.io/${googleId}/${appName}:${tagVersion} -n staging
    echo "Deploying ${appName} ..."
    sleep 5s
    kubectl rollout status deployment/${appName}-deployment -n staging
    sleep 5s
    deployMenu
}

pushImageMenu(){
    clear
    echo "Have you Pushed the Docker Image?"
    echo ------------------------------------------------------------
    echo "1. Yes"
    echo "2. No, do it for me"
    echo "3. Back <-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) finalStep;;
        2) pushImage;;
        3) k8sMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; pushImageMenu;;
    esac  
}

finalStep(){
    clear
    echo "What are you doing?"
    echo ------------------------------------------------------------
    echo "1. Installing"
    echo "2. Deploying new release"
    echo "3. Back to Main Menu<-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) installk8s;;
        2) rolloutImage;;
        3) mainMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; finalStep;;
    esac  
}

pushImage(){
    clear
    echo " Please provide your projectId. e.g: fleet-geode-253715"
    echo ------------------------------------------------------------
    echo
    echo -n "Google Project ID==>"
    read googleId
    echo
    clear
    echo " Please provide the tag version of Docker Image. e.g 1.0"
    echo ------------------------------------------------------------
    echo
    echo -n "Version==>"
    read tagVersion
    echo
    clear
    echo " Please, confirm the Image to push to Registry:"
    echo ------------------------------------------------------------
    echo
    echo "gcr.io/${googleId}/${appName}:${tagVersion}"
    echo 
    echo "1. True"
    echo "2. False"
    echo
    echo -n "Enter Option ==> "
    read booleanId    
    if [[ ${booleanId} -eq 1 ]]; then
        #gcloud docker -- push gcr.io/${googleId}/${appName}:${tagVersion}
        echo "Pushed!"
        sleep 2s
        pushImageMenu
    else
        echo "Ops something went wrong!"
        sleep 2s
        pushImageMenu
    fi    
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
        1) namespaceStaging;;
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
        namespaceStaging
    elif [ ${k8sMenuId} -eq 1 ]
    then
        sed  "s/fleet-geode-253715/${googleId}/g"  front-end/public/k8s/deployments.yaml > front-end/public/k8s/deployments-tmp.yaml    
        cp -rp front-end/public/k8s/deployments-tmp.yaml  front-end/public/k8s/deployments.yaml
        rm -rf front-end/public/k8s/deployments-tmp.yaml
        namespaceStaging 
    elif [ ${k8sMenuId} -eq 2 ]
    then
        sed  "s/fleet-geode-253715/${googleId}/g"  quotes/k8s/deployments.yaml > quotes/k8s/deployments-tmp.yaml    
        cp -rp quotes/k8s/deployments-tmp.yaml  quotes/k8s/deployments.yaml
        rm -rf quotes/k8s/deployments-tmp.yaml
        namespaceStaging 
    elif [ ${k8sMenuId} -eq 3 ]
    then
        sed  "s/fleet-geode-253715/${googleId}/g"  newsfeed/k8s/deployments.yaml > newsfeed/k8s/deployments-tmp.yaml    
        cp -rp newsfeed/k8s/deployments-tmp.yaml  newsfeed/k8s/deployments.yaml
        rm -rf newsfeed/k8s/deployments-tmp.yaml    
        namespaceStaging 
    fi
}

namespaceStaging(){
    clear
    echo " Have you created a staging namespace on k8s?"
    echo ------------------------------------------------------------
    echo "1. Yes"
    echo "2. No, create for me!"
    echo "3. Back <-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) dockerTagMenu;;
        2) createNamespaceStaging;;
        3) k8sMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; namespaceStaging ;;
    esac    
}

dockerTagMenu(){
    clear
    echo "Have you Tagged the Docker Image?"
    echo ------------------------------------------------------------
    echo "1. Yes"
    echo "2. No, do it for me"
    echo "3. Back <-"
    echo "0. Exit!"
    echo -n "Enter Option ==> "
    read MenuId
    echo
    case $MenuId in
        1) pushImageMenu;;
        2) dockerTag;;
        3) k8sMenu;;
        0) exit;;
        *) "Sorry, Invalid Option!"; sleep 2s; echo ; dockerTagMenu;;
    esac 

}

dockerTag(){
    clear
    echo " Please provide the local Docker TAG. e.g quotes:1.0"
    echo ------------------------------------------------------------
    echo
    echo -n "Local Docker TAG==>"
    read dockerLocalTag
    echo
    clear
    echo " Please provide your projectId. e.g: fleet-geode-253715"
    echo ------------------------------------------------------------
    echo
    echo -n "Google Project ID==>"
    read googleId
    echo
    clear
    echo " Please provide the tag version of Docker Image. e.g 1.0"
    echo ------------------------------------------------------------
    echo
    echo -n "Version==>"
    read tagVersion
    echo
    clear
    echo " Please, confirm:"
    echo ------------------------------------------------------------
    echo
    echo "${dockerLocalTag} to gcr.io/${googleId}/${appName}:${tagVersion}"
    echo
    echo "1. True"
    echo "2. False"
    echo
    echo -n "Enter Option ==> "
    read booleanId
    if [[ ${booleanId} -eq 1 ]]; then
        docker tag ${dockerLocalTag} gcr.io/${googleId}/${appName}:${tagVersion}
        echo "TAGGED!"
        sleep 2s
        pushImageMenu
    else
        echo "Ops something wrong!"
        sleep 2s
        dockerTagMenu
    fi    
}


createNamespaceStaging(){
    kubectl create namespace staging
    echo "Namespace staging created"
    sleep 2s
    namespaceStaging
}

installk8s(){
    if [[ ${k8sMenuId} -eq 1 ]]; then
        echo "Installing ${appName} ..."
        kubectl create -f front-end/public/k8s/deployments.yaml
        kubectl create -f front-end/public/k8s/services.yaml
        kubectl create -f front-end/public/k8s/ingress.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    elif [ ${k8sMenuId} -eq 2 ]
    then
        echo "Installing ${appName} ..."
        kubectl create -f quotes/k8s/deployments.yaml
        kubectl create -f quotes/k8s/services.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    elif [ ${k8sMenuId} -eq 3 ]
    then
        echo "Installing ${appName} ..."
        kubectl create -f newsfeed/k8s/deployments.yaml
        kubectl create -f newsfeed/k8s/services.yaml
        echo "${appName} Done !"
        sleep 2s
        k8sMenu
    elif [ ${k8sMenuId} -eq 4 ]
    then
        echo "Installing ${appName} ..."
        kubectl create -f front-end/k8s/secrets.yaml
        kubectl create -f front-end/k8s/deployments.yaml
        kubectl create -f front-end/k8s/services.yaml
        kubectl create -f front-end/k8s/ingress.yaml
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
    cd iac/ && terraform apply -auto-approve
    cd ../
    mainMenu
}

runDockerFrontendStatic(){
    echo "Building docker image ..."
    docker build --tag frontend-static:1.0  --file front-end/public/Dockerfile .
    echo "Running Docker ..."
    docker run --detach --rm --name frontend-static --publish 8000:8000 frontend-static:1.0
    echo "Done!"
    appMenu
}

runDockerQuotes(){
    echo "Building docker image ..."
    docker build --tag quotes:1.0 --file quotes/Dockerfile .
    echo "Running Docker ..."
    docker run --detach --rm --name quotes --hostname quotes --env APP_PORT=8080 quotes:1.0
    echo "Done!"
    appMenu
}

runDockerNewsfeed(){
    echo "Building docker image ..."
    docker build --tag newsfeed:1.0 --file newsfeed/Dockerfile .
    echo "Running Docker ..."
    docker run --detach --rm --name newsfeed --hostname newsfeed --env APP_PORT=8081 newsfeed:1.0
    echo "Done!"
    appMenu
}

runDockerFrontend(){
    echo "Building docker image ..."
    docker build --tag frontend:1.0 --file front-end/Dockerfile .
    echo "Running Docker ..."
    docker run --detach --rm --name frontend --env APP_PORT=8082 --env STATIC_URL=http://0.0.0.0:8000 --env QUOTE_SERVICE_URL=http://quotes:8080 --env NEWSFEED_SERVICE_URL=http://newsfeed:8081 --env  NEWSFEED_SERVICE_TOKEN="T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX" --link quotes:quotes --link  newsfeed:newsfeed --publish 8082:8082 frontend:1.0
    echo "Done!"
    echo "Please try to access: http://localhost:8082"
    sleep 10s
    mainMenu
}

mainMenu