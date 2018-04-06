/*
Copyright 2017 The Kubernetes Authors.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"crypto/tls"
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net"
	"net/http"

	"github.com/golang/glog"
	v1alpha1 "github.com/pmorie/cluster-registry-crd/pkg/apis/clusterregistry/v1alpha1"
	"k8s.io/api/admission/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var (
	certFile string
	keyFile  string
)

type Config struct {
	CertFile string
	KeyFile  string
}

func (c *Config) addFlags() {
	flag.StringVar(&c.CertFile, "tls-cert-file", c.CertFile, ""+
		"File containing the default x509 Certificate for HTTPS. (CA cert, if any, concatenated "+
		"after server cert).")
	flag.StringVar(&c.KeyFile, "tls-private-key-file", c.KeyFile, ""+
		"File containing the default x509 private key matching --tls-cert-file.")
}

func serveCrd(w http.ResponseWriter, r *http.Request) {
	var body []byte
	if r.Body != nil {
		if data, err := ioutil.ReadAll(r.Body); err == nil {
			body = data
		}
	}

	log.Println(string(body))

	//	// verify the content type is accurate
	//	contentType := r.Header.Get("Content-Type")
	//	if contentType != "application/json" {
	//		glog.Errorf("contentType=%s, expect application/json", contentType)
	//		return
	//	}

	//var reviewResponse *v1beta1.AdmissionResponse
	ar := v1beta1.AdmissionReview{}
	//	deserializer := codecs.UniversalDeserializer()
	//	if _, _, err := deserializer.Decode(body, nil, &ar); err != nil {
	//		glog.Error(err)
	//		reviewResponse = toAdmissionResponse(err)
	//	} else {
	//		reviewResponse = admit(ar)
	//	}

	if err := json.Unmarshal(body, &ar); err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	cluster := v1alpha1.Cluster{}
	err := json.Unmarshal(ar.Request.Object.Raw, &cluster)
	if err != nil {
		log.Println(err)
		glog.Error(err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	reviewResponse := v1beta1.AdmissionResponse{Allowed: true}
	v := cluster.Spec.KubernetesAPIEndpoints.ServerEndpoints[1].ServerAddress
	if net.ParseIP(string(v)) == nil {
		reviewResponse.Allowed = false
		reviewResponse.Result = &metav1.Status{
			Reason: "the custom resource contains a malformed IP address",
		}
	}

	log.Printf("Correct IP address formulation", v)

	response := v1beta1.AdmissionReview{}
	if &reviewResponse != nil {
		response.Response = &reviewResponse
	}

	resp, err := json.Marshal(response)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write(resp)
}

func main() {
	var config Config
	config.addFlags()
	flag.Parse()
	//	flag.StringVar(&certFile, "tls-cert-file", c.CertFile, "TLS certificate file.")
	//	flag.StringVar(&keyFile, "tls-private-key-file", c.KeyFile, "TLS key file.")
	http.HandleFunc("/", serveCrd)
	server := &http.Server{
		Addr: ":443",
		TLSConfig: &tls.Config{
			ClientAuth: tls.NoClientCert,
		},
	}
	log.Fatal(server.ListenAndServeTLS("", ""))

}
